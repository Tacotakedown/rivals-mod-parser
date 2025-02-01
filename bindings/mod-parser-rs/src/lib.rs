#![allow(non_snake_case)]

use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use thiserror::Error;

mod ffi;

use ffi::FindAndEncodeThumbnail;

#[derive(Error, Debug)]
pub enum ParserError {
    #[error("File not found")]
    FileNotFound,
    #[error("Invalid UTF-8 sequence")]
    EncodingError,
    #[error("Native parser error: {0}")]
    NativeError(String),
}

pub struct ModParser;

impl ModParser {
    pub fn find_and_encode_thumbnail(root_path: &str) -> Result<String, ParserError> {
        let c_path = CString::new(root_path).map_err(|_| ParserError::EncodingError)?;

        unsafe {
            let result_ptr = FindAndEncodeThumbnail(c_path.into_raw());
            let result = CStr::from_ptr(result_ptr)
                .to_str()
                .map_err(|_| ParserError::EncodingError)?;

            libc::free(result_ptr as *mut libc::c_void);

            if result.starts_with("error:") {
                Err(ParserError::NativeError(result.to_string()))
            } else {
                Ok(result.to_string())
            }
        }
    }
}
