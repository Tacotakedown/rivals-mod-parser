fn main() {
    println!("cargo:rustc-link-search=native=C:/Github/rivals-mod-parser/build");
    println!("cargo:rustc-link-lib=static=mod_parser");
}
