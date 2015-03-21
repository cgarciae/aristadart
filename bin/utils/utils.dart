library utils;

import 'dart:convert';

import 'package:crypto/crypto.dart';

String encryptString(String pass) 
{    
  var toEncrypt = new SHA256();
  toEncrypt.add(UTF8.encode(pass));
  return CryptoUtils.bytesToHex(toEncrypt.close());
}