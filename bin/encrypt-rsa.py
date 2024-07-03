#!/bin/env python
from cryptography.hazmat.primitives.serialization import load_pem_public_key
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import padding
from jwcrypto import jwk
import json

# Javascript code to generate RSA keys
#
# let keyPair = await window.crypto.subtle.generateKey(
#   {
#     name: "RSA-OAEP",
#     modulusLength: 4096,
#     publicExponent: new Uint8Array([1, 0, 1]),
#     hash: "SHA-256",
#   },
#   true,
#   ["encrypt", "decrypt"],
# );
#
# window.crypto.subtle.exportKey("jwk", keyPair.publicKey).then(
#                     function(keydata) {
#                         publicKeyhold = keydata;
#                         publicKeyJson = JSON.stringify(publicKeyhold);
#                         console.log(publicKeyJson);
#                     }
#                 );
# {"alg":"RSA-OAEP-256","e":"AQAB","ext":true,"key_ops":["encrypt"],"kty":"RSA","n":"sMZZaPJGTbQRhJyin5SBCbKa0pFMmfbpXea9ES9tH5m87Ec-uFUe7b62Xy72wwTnl5OVNdWK0Ge2Zh_d8vdryo0o7r58twsoHquKEIKdtpdoAPMdDClvherka4bTXrzbDDwnbOMX1PCPmo7hpViJEHL4rtlm0kwkxOhemAd50NFjDIhCqwQ1Um6zunF4bzuA1htq3MKtxeI7p2TR6CGIq1ztgNHRTh-aPR7ItOT9kKwQY1zlDN6mWFr_XZeVfVdd-Acd9GzijF4_-_TF3T95VYH5hCEHAnI9DG7Smz6xh5rfWq_muRMD8llAxbKdD6v6FhU56uXotU0nF4sIHJkoyNifWVHbKEr6CVMK5F0x4COmq5Q4vVq1QABkhL90tWWXtIoFaxfnJVIDeumMIqREw9j5p4b2F-GJnoVaY1CZQfZm9o1rZETI6bCtndXsyqpCgl3vBFEr5DN4AA7gFrAdcQlCve4l5cVCnZBGEKtKehNaXtcspEjogYq9OhJSHMoiK-5zqMHmx2k9s1eBfCq5_VeiuK3oAo3DknkX66gaGOe5M69n1zyJB32N_pVckyP5z2z23KhAtoLBcXKpkiCuFS9tKzejvOmT5EhugQGzoHyEmGhzYlLyG_jTefRhHmX4NL3L3xdQRcI2hC0rcFxaUbDc4CQUyhNVx9ZlpXgluPU"}
#
# Result of the python encryption
#
# var cipherText = "\xa0w\xd8n\x8dx\xdfsH\xc6\x94z\x04\xe6<\xc0\x17)P\xaaW\xa8\xe6L\x98K\xec>\xb5\x0b\x88\xc6\xd8\xa4~\x8a\xb4\xd6r\x8e\xd1/7\x98\x9aGd\x9b\x93\xccp\x10u\xac\xfaI\xd1 @\xe8\x17\xfcO\xaa\x11\xd6I\xb4\x99\xa3\xc6\xce\x1f\x00\x06c\xadJZ\nM\xaaFj\xac\xba\xb6'\xf06\x16F\xc8D\x05\x16F\x10\x88\xa9m\xbf\xb0BO\x91\xd7\x8e\xad\xb9\x13\x8c3\xccp\x83\xc1\xcd\x05\xab\xb1[\xeb\xd8\x07\x82\xack\xe9\xf9\xf2\x0f\xef\xda\xd6\xb2d\xd5\x0e\xad\xa3\xbc\x9e\x94\x9d\x19\xc4\xf0^\xe7(`n\xcai*\x0fD\x06\xf1\xcePm\x19\xdf\x90\xd9]\xd2\xc479\n\x02\xa4'\x02\x16\xba\xdd\xd0\x1e\xec\x87N\xb2|\xf6o\xbc\x9fu\xa2H\x04\xd6\xd8=<s\xc6\xd9q*-u\xad[\xf1\xbc\x94\xd0rp\x8f'F\x9ac\x9dYT\x15\x1eF\r\xb6b\xf1\xe0L1\xa9\xe6\x04\xa0\x17CsI\xccB \x0eS\xa6X\xc2\x88\xb5\xf8^\x15{\x83\xfb\xee\xd7\x8c\xff,I\xd2$r\xae\x0e\x93\xb6\x90\xed\x8bM\xc5-\xb5ce\x08\x8f\x1a}f?lf\xb4:R\xd7Y\x9d\xb6\x89\xf6\xfaj \xb8S\xb41\xd9\xf5Z\x8f\x95\x1b\x84\xbf\x1d\xe2xzA\xa2\xf8\xce\x90\xd0\xbd\xd2m\xf3]\xe0\x8dV\xe8wl\x89\xbc9\xb9\xab\xeb\xe3M[5.f\xaaG\x8bQ\x8f\x9b[\x19@\xe0'\xfa\x13\xe2d\x07\xcd5Y\x11\xc7<\x99\xaa&T\xa1\x96\xb4 #G\xf0\xe4R^\xdd:\xbfm\x16'\xe4\xa6Kqg1\xea\xcb\xf5\xfbd5\x82\xbc\xcdE\x12\xc5\x93\x1e`M\x10\x00\xf1\xc4z\x80j\x03\xce\x1e\xc21\x97|\xef~\xb3\x17\r\xa2Fq\t+k\x04*Z\xd0\x9b\x87FN\xfd\xbfu\xe3\x0b\xe1{Q\xd5\xcb\xd0`\xbe\x9e\xdf7s-\x81\xab\xdcO:e?8+\xf8Sph\xd5\xfe\x8b\xcftc:d\xf1I\xaf\xd6m\x0b \xf6\xa7\xdf\xa3\x12K\x92\xa9\xe0\x956\x97\xab\xb4\x87a\xa5|\xcf\x0e_\xdc\xad\x95z\x85";
# function arrayBufferToString(str){
#     var byteArray = new Uint8Array(str);
#     var byteString = '';
#     for(var i=0; i < byteArray.byteLength; i++) {
#         byteString += String.fromCodePoint(byteArray[i]);
#     }
#     return byteString;
# }
# function stringToArrayBuffer(str){
#     var buf = new ArrayBuffer(str.length);
#     var bufView = new Uint8Array(buf);
#     for (var i=0, strLen=str.length; i<strLen; i++) {
#         bufView[i] = str.charCodeAt(i);
#     }
#     return buf;
# }
# window.crypto.subtle.decrypt({
#             name: "RSA-OAEP",
#         },
#         keyPair.privateKey, //from generateKey or importKey above
#         stringToArrayBuffer(cipherText) //ArrayBuffer of the data
#     )
#     .then(function(decrypted) {
#         console.log(arrayBufferToString(decrypted));
#     })
#     .catch(function(err) {
#         console.error(err);
#     });

expkey = json.loads(
    '{"alg":"RSA-OAEP-256","e":"AQAB","ext":true,"key_ops":["encrypt"],"kty":"RSA","n":"sMZZaPJGTbQRhJyin5SBCbKa0pFMmfbpXea9ES9tH5m87Ec-uFUe7b62Xy72wwTnl5OVNdWK0Ge2Zh_d8vdryo0o7r58twsoHquKEIKdtpdoAPMdDClvherka4bTXrzbDDwnbOMX1PCPmo7hpViJEHL4rtlm0kwkxOhemAd50NFjDIhCqwQ1Um6zunF4bzuA1htq3MKtxeI7p2TR6CGIq1ztgNHRTh-aPR7ItOT9kKwQY1zlDN6mWFr_XZeVfVdd-Acd9GzijF4_-_TF3T95VYH5hCEHAnI9DG7Smz6xh5rfWq_muRMD8llAxbKdD6v6FhU56uXotU0nF4sIHJkoyNifWVHbKEr6CVMK5F0x4COmq5Q4vVq1QABkhL90tWWXtIoFaxfnJVIDeumMIqREw9j5p4b2F-GJnoVaY1CZQfZm9o1rZETI6bCtndXsyqpCgl3vBFEr5DN4AA7gFrAdcQlCve4l5cVCnZBGEKtKehNaXtcspEjogYq9OhJSHMoiK-5zqMHmx2k9s1eBfCq5_VeiuK3oAo3DknkX66gaGOe5M69n1zyJB32N_pVckyP5z2z23KhAtoLBcXKpkiCuFS9tKzejvOmT5EhugQGzoHyEmGhzYlLyG_jTefRhHmX4NL3L3xdQRcI2hC0rcFxaUbDc4CQUyhNVx9ZlpXgluPU"}'
)


key = jwk.JWK(**expkey)
public_key_pem = key.export_to_pem()
public_key = load_pem_public_key(public_key_pem)
print(key)

message = b"encrypted data"

ciphertext = public_key.encrypt(
    message,
    padding.OAEP(
        mgf=padding.MGF1(algorithm=hashes.SHA256()),
        algorithm=hashes.SHA256(),
        label=None,
    ),
)

print(ciphertext)
