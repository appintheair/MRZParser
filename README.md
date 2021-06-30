[![Swift](https://github.com/appintheair/MRZParser/actions/workflows/swift.yml/badge.svg)](https://github.com/appintheair/MRZParser/actions/workflows/swift.yml)
# MRZParser
Parser [MRZ](https://en.wikipedia.org/wiki/Machine-readable_passport) code for TD1(ID cards), TD2, TD3 (Passports), MRVA (Visas type A), MRVB (Visas type B) types.

## Fields Distribution of Official Travel Documents:
![image](https://raw.githubusercontent.com/appintheair/MRZParser/develop/docs/img/Fields_Distribution.png)
#### Fields description
Field | TD1 description | TD2 description | TD3 description | MRVA description | MRVB description
----- | --------------- | --------------- | --------------- | ---------------- | ----------------
Document type | The first letter shall be 'I', 'A' or 'C' |  <- | Normally 'P' for passport | The First letter must be 'V' | <- |
Country code | 3 letters code (ISO 3166-1) or country name (in English) | <- | <- | <- | <- |
Document number | Document number | <- | <- | <- | <- |
Birth date | Format: YYMMDD | <- | <- | <- | <- |
Sex | Genre. Male: 'M', Female: 'F' or Undefined: 'X', "<" or "" | <- | <- | <- | <- |
Expiry date  | Format: YYMMDD | <- | <- | <- | <- |
Nationality | 3 letters code (ISO 3166-1) or country name (in English) | <- | <- | <- | <- |
Surname | Holder primary identifier(s) | <- | Primary identifier(s) | <- | <- |
Given names | Holder secondary identifier(s) | <- | Secondary identifier(s) | <- | <- |
Optional data | Optional personal data at the discretion of the issuing State. Non-mandatory field. | <- | Personal number. In some countries non-mandatory field. | Optional personal data at the discretion of the issuing State. Non-mandatory field. | <- |
Optional data 2 | Optional personal data at the discretion of the issuing State. Non-mandatory field. | X | X | X | X |

## Installation guide
### Swift Package Manager
```swift
dependencies: [
    .package(url: "https://github.com/appintheair/MRZParser.git", .upToNextMajor(from: "0.0.1"))
]
```
## Usage
The parser is able to validate the MRZ string and parse the MRZ code. Let's start by initializing our parser.
```swift
let parser = MRZParser()
```
For validation we use the method `isLineValid` which returns `Bool`
```swift
parser.isLineValid(line: line)
```
For parsing, we use the `parse` method which returns the `MRZResult` structure with all the necessary data.
```swift
parser.parse(mrzString: mrzString)
```
## Example
### TD1 (ID card)
#### Input
```
I<UTOD231458907<<<<<<<<<<<<<<<
7408122F1204159UTO<<<<<<<<<<<6
ERIKSSON<<ANNA<MARIA<<<<<<<<<<
```
#### Output
Field | Value
----- | -----
Document type | I
Country code | UTO
Document number | D23145890
Birth date | 1974.08.12
Sex | FEMALE
Expiry date  | 2012.04.15
Nationality | UTO
Surname | ERIKSSON
Given names | ANNA MARIA
Optional data | ""
Optional data 2 | ""

### TD2
#### Input
```
I<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<
D231458907UTO7408122F1204159<<<<<<<6
```
#### Output
Field | Value
----- | -----
Document type | I
Country code | UTO
Document number | D23145890
Birth date | 1974.08.12
Sex | FEMALE
Expiry date  | 2012.04.15
Nationality | UTO
Surname | ERIKSSON
Given names | ANNA MARIA
Optional data | ""

### TD3 (Passport)
#### Input
```
P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<
L898902C36UTO7408122F1204159ZE184226B<<<<<10
```
#### Output
Field | Value
----- | -----
Document type | P
Country code | UTO
Document number | L898902C3
Birth date | 1974.08.12
Sex | FEMALE
Expiry date  | 2012.04.15
Nationality | UTO
Surname | ERIKSSON
Given names | ANNA MARIA
Optional data | ZE184226B

### MRVA (Visa type A)
#### Input
```
V<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<
L8988901C4XXX4009078F96121096ZE184226B<<<<<<
```
#### Output
Field | Value
----- | -----
Document type | V
Country code | UTO
Document number | L8988901C
Birth date | 1940.09.07
Sex | FEMALE
Expiry date  | 1996.12.10
Nationality | XXX
Surname | ERIKSSON
Given names | ANNA MARIA
Optional data | 6ZE184226B

### MRVB (Visa type B)
#### Input
```
V<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<
L8988901C4XXX4009078F9612109<<<<<<<<
```
#### Output
Field | Value
----- | -----
Document type | V
Country code | UTO
Document number | L8988901C
Birth date | 1940.09.07
Sex | FEMALE
Expiry date  | 1996.12.10
Nationality | UTO
Surname | ERIKSSON
Given names | ANNA MARIA
Optional data | ""

## License

The library is distributed under the MIT [LICENSE](https://opensource.org/licenses/MIT).
