PKG_NAME = rust

HOMEPAGE   = https://www.rust-lang.org/
COMMENT    = Safe, concurrent, practical language
LICENSE    =

## Cache rust build files
ENV += RUSTUP_HOME=/spksrc/.rustup
ENV += CARGO_HOME=/spksrc/.cargo

/spksrc/.cargo/rustc:
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | env $(ENV) sh -s -- -y --profile minimal
