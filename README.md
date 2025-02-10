# asn1c Extensible Bitstring Example

Minimal example of an issue with the UPER encoding of ASN.1 extensible bitstrings in the open source asn1c compiler.

A real world example of this issue was seen in the 2024 edition of the J2735 specification. See:
https://github.com/CDOT-CV/asn1_codec/pull/37

## Version 1

Here is an ASN.1 specification with an extensible bitstring.  

_Version 1 specification:_
```asn1
FruitSalad ::= SEQUENCE {
   fruits        Fruits,
   servingSize   INTEGER(0..255)
}

Fruits ::= BIT STRING {
   apple       (0),
   orange      (1),
   grape       (2),
   banana      (3)
} (SIZE (4, ...))   -- Size constraint with extensibility marker
```

`Fruits` is a bitstring with 4 items, with an extensibility marker (the three dots '...') in the SIZE constraint, to allow more fruits to be added in later versions.  `FruitSalad` is a sequence of a `Fruits` bitstring and a `servingSize` integer.

Here is an example of a `FruitSalad` value written as XML.  We want apples, oranges, grapes and bananas in our fruit salad, with a serving size of 127 grams:

```XML
<FruitSalad>
    <fruits>
        1111
    </fruits>
    <servingSize>127</servingSize>
</FruitSalad>
```

The Fruit Salad spec was compiled with the usdot fork of the asn1c compiler (vlm_master branch):
https://github.com/usdot-fhwa-stol/usdot-asn1c/

The asn1c compiler was installed in Ubuntu (Windows/WSL), and version 1 of the spec was compiled via:

```bash
asn1c -fcompound-names -fincludes-quoted -pdu=all asn/FruitModule.v1.asn
make -f converter-example.mk
mv converter-example converter-example-v1
```

The XML example was then converted to UPER binary via:

```bash
./converter-example-v1 -p FruitSalad -ixer -ouper FruitSalad.xml > FruitSalad.v1.uper
xxd -ps FruitSalad.v1.uper > FruitSalad.v1.hex
xxd -b FruitSalad.v1.uper > FruitSalad.v1.binarytext
```

The UPER in hex and binary is:

```
hex: 7bf8
binary: 0111101111111000
```

The interpretation of the binary UPER is as follows:

|bits|meaning|
|----|-------|
|0|Extensibility marker.  Indicates that the bitstring is extensible, but is equal to 0 because the size has the base value of 4|
|1111|Value of the bitstring: `apple`, `orange`, `grape`, and `banana` are all set|
|01111111|An 8-bit integer with the serving size of 127|
|000|Padding bits to produce 2 octets|

## Version 2
Next suppose we want to add kiwifruit to our specification while maintaining binary compatibility of the UPER encoding.  We create version 2 and alter the `Fruits` bitstring as:

_Version 2 specification:_
```asn1
Fruits ::= BIT STRING {
   apple       (0),
   orange      (1),
   grape       (2),
   banana      (3),
   kiwifruit   (4)      -- Extension
} (SIZE (4, ..., 5))    -- Size constraint with extension
```

A version 2 bitstring can have either 4 or 5 items.  If we don't actually want kiwifruit, the encoding for our XML and UPER values should be the same.  

We compile version 2:
```bash
asn1c -fcompound-names -fincludes-quoted -pdu=all FruitModule.v2.asn
make -f converter-example.mk
mv converter-example converter-example-v2
```
and then try to read the UPER that we generated from version 1, by converting it to XML:
```bash
./converter-example-v2 -p FruitSalad -iuper -oxer FruitSalad.v1.uper > FruitSalad.v2-from-v1-uper.xml
```

This produces the following XML.

```XML
<FruitSalad>
    <fruits>
        11101
    </fruits>
    <servingSize>252</servingSize>
</FruitSalad>
```
Our fruit salad is all messed up!  We now have kiwifruit that we don't want, and no bananas, that we do want (11101 = apple, orange, grape, kiwifruit). Not only that but the serving size is wrong!  What is going on?

To understand what UPER the Version 2 converter is expecting, we encode the original XML with v2:
```bash
./converter-example-v2 -p FruitSalad -ixer -ouper FruitSalad.xml > FruitSalad.v2.uper
xxd -ps FruitSalad.v2.uper > FruitSalad.v2.hex
xxd -b FruitSalad.v2.uper > FruitSalad.v2.binarytext
```
which gives the following UPER:
```
hex: 3dfc
binary: 0011110111111100
```
The UPER encoding is different from what we got from v1, but it should be identical. This is a bug in asn1c. What exactly is different? Compare the v1 and v2 binary encoding:
```
v1: 0111101111111000
v2: 0011110111111100
```

The 4 bits of the bitstring and the 8 bits of the integer are both still there, but there is an extra 0 inserted before the bitstring.  Why? To understand that, consider the following alternative specification where we initially define the `Fruits` bitstring with a range constraint of 4-5 in the extension root, instead of a fixed size of 4:

_Alternative Fruits with range constraint:_
```asn1
Fruits ::= BIT STRING {
   apple       (0),
   orange      (1),
   grape       (2),
   banana      (3),
   kiwifruit   (4)
} (SIZE (4..5, ...))    -- Size constraint is 4-5. Extensible, but no extension present.
```

If we compile this version of the spec and convert the example XML to UPER, the bits produced are identical to the version 2 encoding. But in this case we are able to interpret the UPER in a way that makes sense:

|bits|meaning|
|----|-------|
|0|Extensibility marker, equal to 0 because the bitstring has no bits set outside the base range of 4-5|
|0|Length determinant of the bitstring.  Since the size can be either 4 or 5, a length determinant is necessary, and consists of a single bit.  The value 0 means the bitstring's length is 4.|
|1111|Value of the bitstring: `apple`, `orange`, `grape`, and `banana` are all set|
|01111111|An 8-bit integer with the serving size of 127|
|00|Padding bits to produce 2 octets|

## The Root Cause
**So the root cause of the mysterious 0-bit inserted by the version 2 codec is that ans1c is incorrectly interpreting the bitstring constraint `SIZE(4, ..., 5)` as identical to `SIZE(4..5, ...)`.**   

But they should not be identical:

`SIZE(4, ..., 5)` means that the bitstring was originally defined with a size of 4, and has an extension added.  But if a specific value of the bitstring has size 4, it is within the extension root and should be encoded the same as if no extension were present, with no length determinant. If the bitstring had length 5, outside the extension root, then it should include a length determinant, but as a "semi-constrained whole number" which would be at least one byte, not as a single bit.

`SIZE(4..5, ...)` means that the bitstring has a size of 4 or 5, both of which are part of the extension root, and it also happens to be extensible, but has no extensions.  So it will always be encoded with a 0 extension bit, and will have a single bit as length determinant so long as no extensions are added.

Compare the generated C code for the two cases:
* [Fruits.c, Version 2 with SIZE(4, ..., 5)](src/v2/Fruits.c)
* [Fruits.c, with SIZE(4..5, ...)](src/RangeConstraint/Fruits.c)

The genereted code for both cases is identical.  Both even include this struct definition with comment indicating that the size constraint is interpreted as an unextended range, line 53:

```c
asn_per_constraints_t asn_PER_type_Fruits_constr_1 CC_NOTUSED = {
	{ APC_UNCONSTRAINED,	-1, -1,  0,  0 },
	{ APC_CONSTRAINED | APC_EXTENSIBLE,  1,  1,  4,  5 }	/* (SIZE(4..5,...)) */,
	0, 0	/* No PER value map */
};
```

See the definition of the `asn_per_constraints_t` struct here:
[per_support.h](src/RangeConstraint/per_support.h).  Examining that, it looks like the contraint specification does not have a way to express which sizes are in the extension root or not.

## The Erlang ASN.1 compiler produces the correct UPER encoding
The Erlang OTP ASN.1 compiler is capable of generating and consuming the correct UPER encoding 
for bitstrings with extensions.  It is useful as a reference and source of truth.  
The extensibility mechanism in ASN.1 was designed with the intention to enable both backward _and forward_ compatibility of successive versions, 
and we would like to be able to take full advantage of that for bitstrings.
To enable that, the UPER encoding for BIT STRINGs *must* have the following properties:

1. The UPER encoding produced by the V1 and V2 encoders must be identical if no bits outside the 
extension root are set.  The V2 codec must be capable of decoding UPER produced by the V1 codec, and vice-versa.
2. A V2 codec must be able to encode and decode a bitstring with an extension correctly 
(we should be able to make fruit salad with kiwifruit).
1. If a V1 decoder receives an UPER bitsting with any bits outside the extension root set, it must be 
capable of ignoring them, and still decoding the extension root correctly. 
We won't get kiwifruit from a V1 decoder, but we will get everything else, and the serving size should 
be correct.  As a bonus, it would be good if the V1 decoder gave us some indication that
that it recognized that extensions were present, even if it wasn't able to fully decode them.

The codec produced by the Erlang ASN.1 compiler meets all three requirements.

### Details on generating and testing the Erlaing codec

Erlang code was generated using the vscode dev container with the 'erlang:27' Dockerhub image.

Run the erlang shell within the dev container:
```bash
cd erlang
erl
```

To generate Erlang codecs for V1 and V2, within the Erlang shell run:
```erlang
asn1ct:compile("FruitModuleV1", [uper, verbose, {i, "./asn"}, {outdir, "./ebin"}]).
asn1ct:compile("FruitModuleV2", [uper, verbose, {i, "./asn"}, {outdir, "./ebin"}]).
```


The Erlang compiler isn't capable of reading XER.  Instead it reads Erlang terms.  
The following terms were used for testing.  In the Erlang shell enter:

```erlang
BasicFruitSalad = {'FruitSalad', [apple, orange, grape, banana], 127}.
ExtendedFruitSalad = {'FruitSalad', [apple, orange, grape, banana, kiwifruit], 127}.
```

#### Test 1.
Test that the V1 and V2 codecs create the same UPER.

Encode the basic fruit salad to UPER with both the V1 and V2 codecs, convert it to hex, and save:

```erlang
{ok, BasicUperV1} = 'FruitModuleV1':encode('FruitSalad', BasicFruitSalad).
{ok, BasicUperV2} = 'FruitModuleV2':encode('FruitSalad', BasicFruitSalad).
file:write_file("BasicUperV1.uper", BasicUperV1).
file:write_file("BasicUperV2.uper", BasicUperV2).

BasicHexV1 = binary:encode_hex(BasicUperV1).
BasicHexV2 = binary:encode_hex(BasicUperV2).
file:write_file("BasicHexV1.hex", BasicHexV1).
file:write_file("BasicHexV2.hex", BasicHexV2).
```


The hex produced by the V1 and V2 Eralng codecs is identical for the extension root:

```
BasicHexV1: 7BF8
BasicHexV2: 7BF8
```

The V1 codec can decode the V1 UPER and vice versa.  Both of these:

```erlang
'FruitModuleV2':decode('FruitSalad', BasicUperV1).
'FruitModuleV1':decode('FruitSalad', BasicUperV2).
```

succeed with the same result:

```erlang
{ok,{'FruitSalad',[apple,orange,grape,banana],127}}
```

Criterion #1 is met.

#### Test 2.
Let's see what the UPER looks like for a bitstring with an extension bit set.

Generate UPER from the V2 codec.  In the Erlang shell:

```erlang
{ok, ExtendedUper} = 'FruitModuleV2':encode('FruitSalad', ExtendedFruitSalad).
ExtendedHex = binary:encode_hex(ExtendedUper).
file:write_file("ExtendedUper.uper", ExtendedUper).
file:write_file("ExtendedHex.hex", ExtendedHex).
```

The UPER with extension is the following:
```
hex: 82FDFC
binary: 100000101111110111111100
```

This is the correct encoding.

The meaning of the bits is as follows:

|bits|meaning|
|----|-------|
|1|Extensibility marker, equal to 1, meaning the length of the bitstring is not within the extension root.|
|00000101|One byte containing the number 5.  This is a semi-constrained whole number containing the length of the bitstring per X.691, Sec 16.6 and 11.7 |
|11111|The value of the bitstring: `apple`, `orange`, `grape`, `banana`, and `kiwifruit` are all set|
|01111111|An 8-bit integer with the serving size of 127|
|00|Padding bits to produce 3 octets|

Encoding the length determinant as a semi-constrained whole number for extensions enables any version of the
codec to recognize and deal with any number of bits for unknown extensions.  Also, the length determinant is only
present when the extension bit is set, so the V1 and V2 encodings remain identical for bitstrings with no extensions.

The V2 codec can decode the UPER with extension that it just created to return the original term:
```erlang
{ok, DecodeV2} = 'FruitModuleV2':decode('FruitSalad', ExtendedUper).
DecodeV2.
```
returns:
```erlang
{'FruitSalad',
    [apple,orange,grape,banana,kiwifruit],
    127}
```

So criterion #2 passes, the V2 codec can both encode and decode the correct encoding.

#### Test 3

Also the V1 codec can decode the UPER with extension:
```erlang
{ok, DecodeV1} = 'FruitModuleV1':decode('FruitSalad', ExtendedUper).
DecodeV1.
```
returns:

```erlang
{'FruitSalad',
    [apple,orange,grape,banana,{bit,4}],
    127}
```

Although it doesn't recognize the "kiwifruit" extension bit by name, it gives reasonable output 
indicating that an extension is present whose name it does't know, and correctly parses the serving size.
So criterion #3 is met, and we have forward compatibility.  An old version of the codec is able to deal with unknown future extensions.


## Files

* `/asn` directory contains the ASN.1 specifications used to generate the C code
* `/src` directory contains the generated C source code
* `/erlang` Output from Erlang examples
    * `/erlang/asn` ASN.1 used to generated Erlang codecs
    * `/erlang/ebin` Generated Erlang source code and compiled code.
* The root directory contains the C converters and C example output.

## Reference

ASN.1 UPER Specification: ITU-T Rec. X.691 (02/21) available from:
https://www.itu.int/rec/T-REC-X.691-202102-I/en
See Chapter 16, "Encoding the bitstring type".  










