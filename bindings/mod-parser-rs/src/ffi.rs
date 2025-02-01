use std::os::raw::c_char;

#[link(name = "mod_parser", kind = "static")]
extern "C" {
    pub fn FindAndEncodeThumbnail(root: *mut c_char) -> *mut c_char;
}
