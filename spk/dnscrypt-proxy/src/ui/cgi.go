package main

import (
    "fmt"
    "os"
    "flag"
    "strings"
    "os/exec"
    "io/ioutil"
    // "io/ioutil"
    "bufio"
    // "bytes"
    "errors"
    "html/template"
    "net/url"
    "regexp"
    "github.com/BurntSushi/toml"
)

var dev *bool

// ref: https://github.com/jedisct1/dnscrypt-proxy/blob/master/dnscrypt-proxy/config.go
type Config struct {
    ListenAddresses []string `toml:"listen_addresses"`
    ServerNames []string `toml:"server_names"`
    SourceIPv6 bool `toml:"ipv6_servers"`
}

type Page struct {
    Title string
    FileData string
    TomlData Config
}

func token() (string, error) {
    cmd := exec.Command("/usr/syno/synoman/webman/login.cgi")
    cmdOut, err := cmd.Output()
    if err != nil && err.Error() != "exit status 255" { // in the Synology world, error code 255 apparently means success!
        return string(cmdOut), err
    }

    // Content-Type: text/html [..] { "SynoToken" : "GqHdJil0ZmlhE", "result" : "success", "success" : true }
    r, err := regexp.Compile("SynoToken\" *: *\"([^\"]+)\"")
    if err != nil {
        return string(cmdOut), err
    }
    token := r.FindSubmatch(cmdOut)
    if len(token) < 1 {
        return string(cmdOut), errors.New("Sorry, you need to login first!")
    }
    return string(token[1]), nil
}


func auth() (string) {
    token, err := token()
    if err != nil {
        logUnauthorised(err.Error())
    }

    // X-SYNO-TOKEN:9WuK4Cf50Vw7Q
    // http://192.168.1.1:5000/webman/3rdparty/DownloadStation/webUI/downloadman.cgi?SynoToken=9WuK4Cf50Vw7Q
    os.Setenv("QUERY_STRING", "SynoToken="+token)
    tempQueryEnv := os.Getenv("QUERY_STRING")
    cmd := exec.Command("/usr/syno/synoman/webman/modules/authenticate.cgi")
    cmdOut, err := cmd.Output()
    if err != nil {
        logUnauthorised(err.Error())
    }
    os.Setenv("QUERY_STRING", tempQueryEnv)

    return string(cmdOut)
}

func logError(str string) { // dump and die
    fmt.Println("Status: 500 Internal server error\nContent-Type: text/html; charset=utf-8\n\n")
    fmt.Println(str)
    os.Exit(0)
}

func logUnauthorised(str string) { // dump and die
    fmt.Println("Status: 401 Unauthorized\nContent-Type: text/html; charset=utf-8\n\n")
    fmt.Println(str)
    os.Exit(0)
}

func loadConfig(configFile string) (*Config, error) {
    if _, err := os.Stat(configFile); os.IsNotExist(err) {
        return nil, errors.New("Config file does not exist.")
    } else if err != nil {
        return nil, err
    }

    var conf Config
    if _, err := toml.DecodeFile(configFile, &conf); err != nil {
        return nil, err
    }

    return &conf, nil
}

func loadFile(file string) (string) {
    data, err := ioutil.ReadFile(file)
    if err != nil {
        logError(err.Error())
    }
    return string(data)
}

func saveFile(file string, data string) {
    // change permission so that 'system' can write to file
    // if err := os.Chown(file, os.Getgid(), 0); err != nil {
    //     logError(err.Error())
    // }

    err := ioutil.WriteFile(file, []byte(data), 0644)
    if err != nil {
        logError(err.Error())
    }
    return
}

func renderHtml(configFile string) {
    var page Page
    fileData := loadFile(configFile)

    conf, err := loadConfig(configFile)
    if err != nil {
        logError(err.Error())
    }

    tmpl, err := template.ParseFiles("layout.html")
    if err != nil {
        logError(err.Error())
    }

    page.Title = "DNSCrypt-proxy"
    page.FileData = fileData
    page.TomlData = *conf
    fmt.Println("Status: 200 OK\nContent-Type: text/html; charset=utf-8\n")
    tmpl.Execute(os.Stdout, page)
    if err != nil {
        logError(err.Error())
    }
}

// func renderHtmlFromToml(configFile string) {

//     conf, err := loadConfig(configFile)
//     if err != nil {
//         logError(err.Error())
//     }

//     tmpl, err := template.ParseFiles("layout.html")
//     if err != nil {
//         logError(err.Error())
//     }

//     conf.Title = "DNSCrypt-proxy"
//     fmt.Println("Status: 200 OK\nContent-Type: text/html; charset=utf-8\n\n")
//     tmpl.Execute(os.Stdout, conf)
//     if err != nil {
//         logError(err.Error())
//     }
// }

func getPost() (string) {
    // get data
    s := bufio.NewScanner(os.Stdin)
    var data string
    for s.Scan() {
        data+=s.Text()+"\n"
    }
    // unescape url chars
    data, err := url.QueryUnescape(data)
    if err != nil {
        logError("bad data: "+data)
    }

    // logError("data: "+data)
    // split on &
    return data
}

func readPost() (string) {
    params := getPost()
    pararmSearch := "file="

    if (strings.HasPrefix(params, pararmSearch)) {
        fileData := string([]rune(params)[len(pararmSearch):])
        return fileData
    }
    // readPostAsToml()
    return ""
}

// func readPostAsToml() {
//         // split on &
//         params := getPost()

//         var conf Config
//         for _, param := range params {
//             param = strings.Trim(param, " \n")
//             tmp := strings.Split(param, "=")

//             if tmp[0] == "ListenAddresses" { // todo: dynamically insert the data
//                 tmp1 := strings.Split(tmp[1], " ")
//                 conf.ListenAddresses = tmp1
//             }
//             if tmp[0] == "ServerNames" {
//                 tmp1 := strings.Split(tmp[1], " ")
//                 conf.ServerNames = tmp1
//             }
//             if tmp[0] == "SourceIPv6" {
//                 if tmp[1] == "true" {
//                     conf.SourceIPv6 = true
//                 } else {
//                     conf.SourceIPv6 = false
//                 }
//             }
//         }
//         buf := new(bytes.Buffer)
//         if err := toml.NewEncoder(buf).Encode(conf); err != nil {
//             logError(err.Error())
//         }
//         logError(buf.String()) // toml data
//         // logError("data: "+data)
// }

func main() {
    // Todo:
    // parse POST params
    // save pref changes
    // fix-up error handling with correct http responses
    // worry about csrf
    // add css
    // Done:
    // get settings from config file
    // Check authorisation
    // send csrf token
    // fix image icons

    dev = flag.Bool("dev", false, "Turns Authentication check off")
    flag.Parse()

    configFile := "/var/packages/dnscrypt-proxy/target/var/dnscrypt-proxy.toml"

    if !*dev {
        auth()
    }
    if *dev {
        configFile = "example-dnscrypt-proxy.toml"
    }
// -------------


    method := os.Getenv("REQUEST_METHOD")
    if method == "POST" {
        if fileData := readPost(); fileData != "" {
            saveFile(configFile, fileData)
        }
        // readPostAsToml()
    }

    // renderHtmlFromToml(configFile)
    renderHtml(configFile)
}