[![Swift](https://github.com/romanmazeev/MRZParser/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/romanmazeev/MRZParser/actions/workflows/swift.yml)
# MRZParser
Parser MRZ code for TD1, TD2, TD3, MRVA (Visas type A), MRVB (Visas type B) types.

## Parsing description:
#### TD1's (id cards):

    Params:                      Case insensitive

        document_type    (str):  The first letter shall be 'I', 'A' or 'C'
        country_code     (str):  3 letters code (ISO 3166-1) or country name (in English)
        document_number  (str):  Document number
        birth_date       (str):  YYMMDD
        sex              (str):  Genre. Male: 'M', Female: 'F' or Undefined: 'X', "<" or ""
        expiry_date      (str):  YYMMDD
        nationality      (str):  3 letters code (ISO 3166-1) or country name (in English)
        surname          (str):  Holder primary identifier(s). This field will be transliterated
        given_names      (str):  Holder secondary identifier(s). This field will be transliterated
        optional_data1   (str):  Optional personal data at the discretion of the issuing State.
                                 Non-mandatory field. Empty string by default
        optional_data2   (str):  Optional personal data at the discretion of the issuing State.
                                 Non-mandatory field. Empty string by default
        transliteration (dict):  Transliteration dictionary for non-ascii chars. Latin based by default
        force           (bool):  Disables checks for country, nationality and document_type fields.
                                 Allows to use 3-letter-codes not included in the countries dictionary
                                 and to use document_type codes without restrictions.
                                 
#### TD2

    Params:                      Case insensitive

        document_type    (str):  The first letter shall be 'I', 'A' or 'C'
        country_code     (str):  3 letters code (ISO 3166-1) or country name (in English)
        surname          (str):  Holder primary identifier(s). This field will be transliterated.
        given_names      (str):  Holder secondary identifier(s). This field will be transliterated.
        document_number  (str):  Document number.
        nationality      (str):  3 letters code (ISO 3166-1) or country name
        birth_date       (str):  YYMMDD
        sex              (str):  Genre. Male: 'M', Female: 'F' or Undefined: 'X', "<" or ""
        expiry_date      (str):  YYMMDD
        optional_data    (str):  Optional personal data at the discretion of the issuing State.
                                 Non-mandatory field. Empty string by default
        transliteration (dict):  Transliteration dictionary for non-ascii chars. Latin based by default
        force           (bool):  Disables checks for country, nationality and document_type fields.
                                 Allows to use 3-letter-codes not included in the countries dictionary
                                 and to use document_type codes without restrictions.
                                 
#### TD3 (Passports)

    Params:                      Case insensitive

        document_type    (str):  Normally 'P' for passport
        country_code     (str):  3 letters code (ISO 3166-1) or country name (in English)
        surname          (str):  Primary identifier(s)
        given_names      (str):  Secondary identifier(s)
        document_number  (str):  Document number
        nationality      (str):  3 letters code (ISO 3166-1) or country name
        birth_date       (str):  YYMMDD
        sex              (str):  Genre. Male: 'M', Female: 'F' or Undefined: 'X', "<" or ""
        expiry_date      (str):  YYMMDD
        optional data    (str):  Personal number. In some countries non-mandatory field. Empty string by default
        transliteration (dict):  Transliteration dictionary for non-ascii chars. Latin based by default
        force           (bool):  Disables checks for country, nationality and document_type fields.
                                 Allows to use 3-letter-codes not included in the countries dictionary
                                 and to use document_type codes without restrictions.
                                 
#### MRVA (Visas type A)

    Params:                      Case insensitive
    
        document_type    (str):  The First letter must be 'V'
        country_code     (str):  3 letters code (ISO 3166-1) or country name (in English)
        surname          (str):  Primary identifier(s)
        given_names      (str):  Secondary identifier(s)
        document_number  (str):  Document number
        nationality      (str):  3 letters code (ISO 3166-1) or country name
        birth_date       (str):  YYMMDD
        sex              (str):  Genre. Male: 'M', Female: 'F' or Undefined: 'X', "<" or ""
        expiry_date      (str):  YYMMDD
        optional_data    (str):  Optional personal data at the discretion of the issuing State.
                                 Non-mandatory field. Empty string by default.
        transliteration (dict):  Transliteration dictionary for non-ascii chars. Latin based by default
        force           (bool):  Disables checks for country, nationality and document_type fields.
                                 Allows to use 3-letter-codes not included in the countries dictionary
                                 and to use document_type codes without restrictions.
                          
#### MRVB (Visas type B)

    Params:                      Case insensitive
    
        document_type    (str):  The First letter must be 'V'
        country_code     (str):  3 letters code (ISO 3166-1) or country name (in English)
        surname          (str):  Primary identifier(s)
        given_names      (str):  Secondary identifier(s)
        document_number  (str):  Document number
        nationality      (str):  3 letters code (ISO 3166-1) or country name
        birth_date       (str):  YYMMDD
        sex              (str):  Genre. Male: 'M', Female: 'F' or Undefined: 'X', "<" or ""
        expiry_date      (str):  YYMMDD
        optional_data    (str):  Optional personal data at the discretion of the issuing State.
                                 Non-mandatory field. Empty string by default.
        transliteration (dict):  Transliteration dictionary for non-ascii chars. Latin based by default
        force           (bool):  Disables checks for country, nationality and document_type fields.
                                 Allows to use 3-letter-codes not included in the countries dictionary
                                 and to use document_type codes without restrictions.
