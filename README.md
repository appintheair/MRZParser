[![Swift](https://github.com/romanmazeev/MRZParser/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/romanmazeev/MRZParser/actions/workflows/swift.yml)
# MRZParser
Parser MRZ code for TD1, TD2, TD3, MRVA (Visas type A), MRVB (Visas type B) types.

## Fields Distribution of Official Travel Documents:
![image](https://raw.githubusercontent.com/appintheair/MRZParser/develop/docs/img/Fields_Distribution.png)
#### TD1's (id cards):

    Params:                      Case insensitive

        document_type         :  The first letter shall be 'I', 'A' or 'C'
        country_code          :  3 letters code (ISO 3166-1) or country name (in English)
        document_number       :  Document number
        birth_date            :  YYMMDD
        sex                   :  Genre. Male: 'M', Female: 'F' or Undefined: 'X', "<" or ""
        expiry_date           :  YYMMDD
        nationality           :  3 letters code (ISO 3166-1) or country name (in English)
        surname               :  Holder primary identifier(s). This field will be transliterated
        given_names           :  Holder secondary identifier(s). This field will be transliterated
        optional_data1        :  Optional personal data at the discretion of the issuing State.
                                 Non-mandatory field. Empty string by default
        optional_data2        :  Optional personal data at the discretion of the issuing State.
                                 Non-mandatory field. Empty string by default                        
#### TD2

    Params:                      Case insensitive

        document_type         :  The first letter shall be 'I', 'A' or 'C'
        country_code          :  3 letters code (ISO 3166-1) or country name (in English)
        surname               :  Holder primary identifier(s). This field will be transliterated.
        given_names           :  Holder secondary identifier(s). This field will be transliterated.
        document_number       :  Document number.
        nationality           :  3 letters code (ISO 3166-1) or country name
        birth_date            :  YYMMDD
        sex                   :  Genre. Male: 'M', Female: 'F' or Undefined: 'X', "<" or ""
        expiry_date           :  YYMMDD
        optional_data         :  Optional personal data at the discretion of the issuing State.
                                 Non-mandatory field. Empty string by default                         
#### TD3 (Passports)

    Params:                      Case insensitive

        document_type         :  Normally 'P' for passport
        country_code          :  3 letters code (ISO 3166-1) or country name (in English)
        surname               :  Primary identifier(s)
        given_names           :  Secondary identifier(s)
        document_number       :  Document number
        nationality           :  3 letters code (ISO 3166-1) or country name
        birth_date            :  YYMMDD
        sex                   :  Genre. Male: 'M', Female: 'F' or Undefined: 'X', "<" or ""
        expiry_date           :  YYMMDD
        optional data         :  Personal number. In some countries non-mandatory field. Empty string by default
#### MRVA (Visas type A)

    Params:                      Case insensitive
    
        document_type         :  The First letter must be 'V'
        country_code          :  3 letters code (ISO 3166-1) or country name (in English)
        surname               :  Primary identifier(s)
        given_names           :  Secondary identifier(s)
        document_number       :  Document number
        nationality           :  3 letters code (ISO 3166-1) or country name
        birth_date            :  YYMMDD
        sex                   :  Genre. Male: 'M', Female: 'F' or Undefined: 'X', "<" or ""
        expiry_date           :  YYMMDD
        optional_data         :  Optional personal data at the discretion of the issuing State.
                                 Non-mandatory field. Empty string by default.                          
#### MRVB (Visas type B)

    Params:                      Case insensitive
    
        document_type         :  The First letter must be 'V'
        country_code          :  3 letters code (ISO 3166-1) or country name (in English)
        surname               :  Primary identifier(s)
        given_names           :  Secondary identifier(s)
        document_number       :  Document number
        nationality           :  3 letters code (ISO 3166-1) or country name
        birth_date            :  YYMMDD
        sex                   :  Genre. Male: 'M', Female: 'F' or Undefined: 'X', "<" or ""
        expiry_date           :  YYMMDD
        optional_data         :  Optional personal data at the discretion of the issuing State.
                                 Non-mandatory field. Empty string by default.
