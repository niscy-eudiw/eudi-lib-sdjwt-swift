/*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import Foundation

let key =
  """
  {
    "kty": "EC",
    "crv": "P-256",
    "x": "b28d4MwZMjw8-00CG4xfnn9SLMVMM19SlqZpVb_uNtQ",
    "y": "Xv5zWwuoaTgdS6hV43yI6gBwTnjukmFQQnJ_kCxzqk8"
  }
  """
  .clean()
// Key Pairs Used in the examples
let holdersKeyPair = generateES256KeyPair()

let issuersKeyPair = generateES256KeyPair()

struct SDJWTConstants {
  
  static let compactSdJwt = "eyJhbGciOiAiRVMyNTYiLCAidHlwIjogImV4YW1wbGUrc2Qtand0In0.eyJfc2QiOiBbIkNyUWU3UzVrcUJBSHQtbk1ZWGdjNmJkdDJTSDVhVFkxc1VfTS1QZ2tqUEkiLCAiSnpZakg0c3ZsaUgwUjNQeUVNZmVadTZKdDY5dTVxZWhabzdGN0VQWWxTRSIsICJQb3JGYnBLdVZ1Nnh5bUphZ3ZrRnNGWEFiUm9jMkpHbEFVQTJCQTRvN2NJIiwgIlRHZjRvTGJnd2Q1SlFhSHlLVlFaVTlVZEdFMHc1cnREc3JaemZVYW9tTG8iLCAiWFFfM2tQS3QxWHlYN0tBTmtxVlI2eVoyVmE1TnJQSXZQWWJ5TXZSS0JNTSIsICJYekZyendzY002R242Q0pEYzZ2Vks4QmtNbmZHOHZPU0tmcFBJWmRBZmRFIiwgImdiT3NJNEVkcTJ4Mkt3LXc1d1BFemFrb2I5aFYxY1JEMEFUTjNvUUw5Sk0iLCAianN1OXlWdWx3UVFsaEZsTV8zSmx6TWFTRnpnbGhRRzBEcGZheVF3TFVLNCJdLCAiaXNzIjogImh0dHBzOi8vaXNzdWVyLmV4YW1wbGUuY29tIiwgImlhdCI6IDE2ODMwMDAwMDAsICJleHAiOiAxODgzMDAwMDAwLCAic3ViIjogInVzZXJfNDIiLCAibmF0aW9uYWxpdGllcyI6IFt7Ii4uLiI6ICJwRm5kamtaX1ZDem15VGE2VWpsWm8zZGgta284YUlLUWM5RGxHemhhVllvIn0sIHsiLi4uIjogIjdDZjZKa1B1ZHJ5M2xjYndIZ2VaOGtoQXYxVTFPU2xlclAwVmtCSnJXWjAifV0sICJfc2RfYWxnIjogInNoYS0yNTYiLCAiY25mIjogeyJqd2siOiB7Imt0eSI6ICJFQyIsICJjcnYiOiAiUC0yNTYiLCAieCI6ICJUQ0FFUjE5WnZ1M09IRjRqNFc0dmZTVm9ISVAxSUxpbERsczd2Q2VHZW1jIiwgInkiOiAiWnhqaVdXYlpNUUdIVldLVlE0aGJTSWlyc1ZmdWVjQ0U2dDRqVDlGMkhaUSJ9fX0.ZfSxIFLHf7f84WIMqt7Fzme8-586WutjFnXH4TO5XuWG_peQ4hPsqDpiMBClkh2aUJdl83bwyyOriqvdFra-bg~WyIyR0xDNDJzS1F2ZUNmR2ZyeU5STjl3IiwgImdpdmVuX25hbWUiLCAiSm9obiJd~WyJlbHVWNU9nM2dTTklJOEVZbnN4QV9BIiwgImZhbWlseV9uYW1lIiwgIkRvZSJd~WyI2SWo3dE0tYTVpVlBHYm9TNXRtdlZBIiwgImVtYWlsIiwgImpvaG5kb2VAZXhhbXBsZS5jb20iXQ~WyJlSThaV205UW5LUHBOUGVOZW5IZGhRIiwgInBob25lX251bWJlciIsICIrMS0yMDItNTU1LTAxMDEiXQ~WyJRZ19PNjR6cUF4ZTQxMmExMDhpcm9BIiwgInBob25lX251bWJlcl92ZXJpZmllZCIsIHRydWVd~WyJBSngtMDk1VlBycFR0TjRRTU9xUk9BIiwgImFkZHJlc3MiLCB7InN0cmVldF9hZGRyZXNzIjogIjEyMyBNYWluIFN0IiwgImxvY2FsaXR5IjogIkFueXRvd24iLCAicmVnaW9uIjogIkFueXN0YXRlIiwgImNvdW50cnkiOiAiVVMifV0~WyJQYzMzSk0yTGNoY1VfbEhnZ3ZfdWZRIiwgImJpcnRoZGF0ZSIsICIxOTQwLTAxLTAxIl0~WyJHMDJOU3JRZmpGWFE3SW8wOXN5YWpBIiwgInVwZGF0ZWRfYXQiLCAxNTcwMDAwMDAwXQ~WyJsa2x4RjVqTVlsR1RQVW92TU5JdkNBIiwgIlVTIl0~WyJuUHVvUW5rUkZxM0JJZUFtN0FuWEZBIiwgIkRFIl0~"
  
  static let payload = "eyJfc2QiOiBbIkNyUWU3UzVrcUJBSHQtbk1ZWGdjNmJkdDJTSDVhVFkxc1VfTS1QZ2tqUEkiLCAiSnpZakg0c3ZsaUgwUjNQeUVNZmVadTZKdDY5dTVxZWhabzdGN0VQWWxTRSIsICJQb3JGYnBLdVZ1Nnh5bUphZ3ZrRnNGWEFiUm9jMkpHbEFVQTJCQTRvN2NJIiwgIlRHZjRvTGJnd2Q1SlFhSHlLVlFaVTlVZEdFMHc1cnREc3JaemZVYW9tTG8iLCAiWFFfM2tQS3QxWHlYN0tBTmtxVlI2eVoyVmE1TnJQSXZQWWJ5TXZSS0JNTSIsICJYekZyendzY002R242Q0pEYzZ2Vks4QmtNbmZHOHZPU0tmcFBJWmRBZmRFIiwgImdiT3NJNEVkcTJ4Mkt3LXc1d1BFemFrb2I5aFYxY1JEMEFUTjNvUUw5Sk0iLCAianN1OXlWdWx3UVFsaEZsTV8zSmx6TWFTRnpnbGhRRzBEcGZheVF3TFVLNCJdLCAiaXNzIjogImh0dHBzOi8vaXNzdWVyLmV4YW1wbGUuY29tIiwgImlhdCI6IDE2ODMwMDAwMDAsICJleHAiOiAxODgzMDAwMDAwLCAic3ViIjogInVzZXJfNDIiLCAibmF0aW9uYWxpdGllcyI6IFt7Ii4uLiI6ICJwRm5kamtaX1ZDem15VGE2VWpsWm8zZGgta284YUlLUWM5RGxHemhhVllvIn0sIHsiLi4uIjogIjdDZjZKa1B1ZHJ5M2xjYndIZ2VaOGtoQXYxVTFPU2xlclAwVmtCSnJXWjAifV0sICJfc2RfYWxnIjogInNoYS0yNTYiLCAiY25mIjogeyJqd2siOiB7Imt0eSI6ICJFQyIsICJjcnYiOiAiUC0yNTYiLCAieCI6ICJUQ0FFUjE5WnZ1M09IRjRqNFc0dmZTVm9ISVAxSUxpbERsczd2Q2VHZW1jIiwgInkiOiAiWnhqaVdXYlpNUUdIVldLVlE0aGJTSWlyc1ZmdWVjQ0U2dDRqVDlGMkhaUSJ9fX0"
  
  static let disclosures = [
    "WyJlSThaV205UW5LUHBOUGVOZW5IZGhRIiwgInBob25lX251bWJlciIsICIrMS0yMDItNTU1LTAxMDEiXQ",
    "WyJRZ19PNjR6cUF4ZTQxMmExMDhpcm9BIiwgInBob25lX251bWJlcl92ZXJpZmllZCIsIHRydWVd",
    "WyJlbHVWNU9nM2dTTklJOEVZbnN4QV9BIiwgImZhbWlseV9uYW1lIiwgIkRvZSJd",
    "WyJQYzMzSk0yTGNoY1VfbEhnZ3ZfdWZRIiwgImJpcnRoZGF0ZSIsICIxOTQwLTAxLTAxIl0",
    "WyJsa2x4RjVqTVlsR1RQVW92TU5JdkNBIiwgIlVTIl0",
    "WyJuUHVvUW5rUkZxM0JJZUFtN0FuWEZBIiwgIkRFIl0",
    "WyJBSngtMDk1VlBycFR0TjRRTU9xUk9BIiwgImFkZHJlc3MiLCB7InN0cmVldF9hZGRyZXNzIjogIjEyMyBNYWluIFN0IiwgImxvY2FsaXR5IjogIkFueXRvd24iLCAicmVnaW9uIjogIkFueXN0YXRlIiwgImNvdW50cnkiOiAiVVMifV0",
    "WyIyR0xDNDJzS1F2ZUNmR2ZyeU5STjl3IiwgImdpdmVuX25hbWUiLCAiSm9obiJd",
    "WyJHMDJOU3JRZmpGWFE3SW8wOXN5YWpBIiwgInVwZGF0ZWRfYXQiLCAxNTcwMDAwMDAwXQ",
    "WyI2SWo3dE0tYTVpVlBHYm9TNXRtdlZBIiwgImVtYWlsIiwgImpvaG5kb2VAZXhhbXBsZS5jb20iXQ"
  ]
  
  static let signature = "ZfSxIFLHf7f84WIMqt7Fzme8-586WutjFnXH4TO5XuWG_peQ4hPsqDpiMBClkh2aUJdl83bwyyOriqvdFra-bg"
  static let protected = "eyJhbGciOiAiRVMyNTYiLCAidHlwIjogImV4YW1wbGUrc2Qtand0In0"
  
  static let x509_sd_jwt = """
                eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsIng1YyI6WyJNSUlEbmpDQ0FvYWdBd0lCQWdJVWVMVi9kOGpiOUJqODFDelZwNHJzN0pobnlnc3dEUVlKS29aSWh2Y05BUUVMQlFBd1d6RUxNQWtHQTFVRUJoTUNWVk14Q3pBSkJnTlZCQWdNQWtOQk1Rc3dDUVlEVlFRSERBSlRSakVZTUJZR0ExVUVDZ3dQU1c1MFpYSnRaV1JwWVhSbElFTkJNUmd3RmdZRFZRUUREQTlKYm5SbGNtMWxaR2xoZEdVZ1EwRXdIaGNOTWpReE1EQXlNRFkwTXpNMldoY05NalV4TURBeU1EWTBNek0yV2pCV01Rc3dDUVlEVlFRR0V3SlZVekVMTUFrR0ExVUVDQXdDUTBFeEN6QUpCZ05WQkFjTUFsTkdNUkl3RUFZRFZRUUtEQWxNWldGbUlFTmxjblF4R1RBWEJnTlZCQU1NRUd4bFlXWXVaWGhoYlhCc1pTNWpiMjB3Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLQW9JQkFRRFBBRFpRbTdiSWd1a2hERVFIbEhmdGQyVVJIQ3hYQ1QrMTJJc2NmaEhNSU4zS2tJdkNWTXZZQTlwMjBZZTJqeVd5UjJKZHdNZ2RQQnZBMWJJVXNnNENTaUE0M2sybWZnREo4NFRHQkNNK1BCYXQwbWhWZGc5QmtqTlBBb1BBWndSOHN5Q3B3NEszNVY4WmpmaEdJSUhVL1ZTdWsrTEFrc3l0MEpNdTAvMnFZK0l1VmtzWDh4UXlyV2lPOUlNQlZuK21JMmRsSWQwMmFzeDFxaGRkRkhPMXRSUGxTdHFpMGdGSjNtb0RDSW40dGR3d2lHV1lkUkFqalBvNVR2Wkw5SnVZQVZQS1VhdlpqZnpUSDZTeWU1dDBJVjR4MGxMSUppTUVrS0pnZGpwSmJ3OS8vL0V1ZVlVNENDYkNaR1N6THpZWTlwVTNJUWRHb05VWTdnckloYlZOQWdNQkFBR2pYekJkTUJzR0ExVWRFUVFVTUJLQ0VHeGxZV1l1WlhoaGJYQnNaUzVqYjIwd0hRWURWUjBPQkJZRUZOM3hSV3N6NHI5ZEZvSUgxNzNySGZvNEdEOWNNQjhHQTFVZEl3UVlNQmFBRkNkdTRQcXFPMHdLQTBKMWc0dTA0bzkycDRlc01BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQldJbU02TnBDaG5uUjJpUkp3M3d2SXZpTHIwWWNyZG41cTZoa3FQbk1JYXhaVy9lOFNDb29FT2o5TWpGMHJBc1RSQmxteUJJclJuTWw2b3hUNFBtVUhpVURPUXJ4Wk9saGRLOHJKVGZXVm5UVGErUFBibFZvZkdkellrQm1YVUNQYjdhY0JlYWJmQzRLNG92SEs2cFdQSzlJMUlGZmhWZ1hubHpBNWw5WE9nd1Q4OFNJbkFBRmVzRDMyNlVuTnRNUFNlb212MjI5Q1lVYU1QckhRL2RBYlBvajJnQkJCWFd0QkZSaWhMTURmWkZUQTNHZ0FhU2lWVUgwZ2tiUEtOY0R3NDRCMXpaNjdIaWFkZzBpQTBwaFRBWGxROGQxa3JaWVR6WUFlajZ3VVdoUytGRHRERTlYZE5hL3RCZEpuaXRjbFhtZnVxZDJZd1VJaUtTRUtPdGd0IiwiTUlJRGRqQ0NBbDZnQXdJQkFnSVVHYkRKQlFjbFh5YVZ1K1FXY1JnZDcrczVNU1V3RFFZSktvWklodmNOQVFFTEJRQXdTekVMTUFrR0ExVUVCaE1DVlZNeEN6QUpCZ05WQkFnTUFrTkJNUXN3Q1FZRFZRUUhEQUpUUmpFUU1BNEdBMVVFQ2d3SFVtOXZkQ0JEUVRFUU1BNEdBMVVFQXd3SFVtOXZkQ0JEUVRBZUZ3MHlOREV3TURJd05qUXpNRGxhRncweU9URXdNREV3TmpRek1EbGFNRnN4Q3pBSkJnTlZCQVlUQWxWVE1Rc3dDUVlEVlFRSURBSkRRVEVMTUFrR0ExVUVCd3dDVTBZeEdEQVdCZ05WQkFvTUQwbHVkR1Z5YldWa2FXRjBaU0JEUVRFWU1CWUdBMVVFQXd3UFNXNTBaWEp0WldScFlYUmxJRU5CTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUF0dTVad3QzMzBCOE9Ccm50UU5IZWg5WDZScDZsbkxPaUErZzdIOThzWWlSN1JteTE1TVRLR3UrNFZhRmJPdVR6anBkUjk1NTlzT050L2RyMFdtTEt3bXhHamFYd3FMcFdHZmVsV1NtQnJuakZ4cjNFS0p2S0VCZU5CL2UyY2ViSjlSdU8vWGlLT0NKcFdGdlIxRlp1OFJtS1QySWFoZXlKVDhlQmx3Q1VKUzZvOGo0RkRTYXhtQThUbXo3Y1kwL1VjUnlnKzhZRVRxTDNGZkRZS0doM0NNU013RlVKb3F3UE9ZaHZlMGVRWWFGek9FTTVIUUJ4cFpOdnJZemVxTm42cmU0cjZpSHZyM2doQ3JaNW9tSnBzTVN5ZGEzeTRUMW1zOUl3TFZsWUlESVZsd0dHSmpZNGU2ejloWUpaYytQTmc4OUtGeTNMMWlhY29lVjFWc0dNNndJREFRQUJvMEl3UURBZEJnTlZIUTRFRmdRVUoyN2crcW83VEFvRFFuV0RpN1RpajNhbmg2d3dId1lEVlIwakJCZ3dGb0FVV1RzSVZBaHhIaTNObEVGSEx5YU12OFJqa2Nzd0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFHZzNkMFJ3UlczbXdDN1BSZERlSExsYTZEcmhhTXRra2JkWHJqb3VjZHpkM0tmWlIrdTM1U1h4eXdxUkVHWit5cUhhQjFGOFovcXlPYVN1M3N6MjNYKyt0YWdiQ21qYklGSGdDSWpua0RsK2twWUVhOTdQYXBzSDJlMndNc095MDNVMjBXajFNUkpjT0ZrUk5sd014dWZoL05iY2pYejdGUHhOaDJ1OFluRER1R0VGVFM2L3g3WHFNMFlVOWRXNDUrdXV5V3BxTnFYcHRzL3d1SXNSZzk4ZXdHblhuMC80S0ttYjRaNGhmZ0xnNmdFU2NoYy8velJDekxqWjgvZ0lOSjFyUk00aUlrdUxIN240OFRPMm0yanlsWmRueGpoQmsvUmtuYVVSWFZ1Q0hlNW16Rks3enNKR3orOU9rY2tBYS9VUDdUa1ozTmJvY1BoUXZlU1k3UzA9IiwiTUlJRGR6Q0NBbCtnQXdJQkFnSVVRNXN2WDZ2RkpPMWY5TjMvczVvYXB4RXZwb2N3RFFZSktvWklodmNOQVFFTEJRQXdTekVMTUFrR0ExVUVCaE1DVlZNeEN6QUpCZ05WQkFnTUFrTkJNUXN3Q1FZRFZRUUhEQUpUUmpFUU1BNEdBMVVFQ2d3SFVtOXZkQ0JEUVRFUU1BNEdBMVVFQXd3SFVtOXZkQ0JEUVRBZUZ3MHlOREV3TURJd05qUXlORFphRncwek5EQTVNekF3TmpReU5EWmFNRXN4Q3pBSkJnTlZCQVlUQWxWVE1Rc3dDUVlEVlFRSURBSkRRVEVMTUFrR0ExVUVCd3dDVTBZeEVEQU9CZ05WQkFvTUIxSnZiM1FnUTBFeEVEQU9CZ05WQkFNTUIxSnZiM1FnUTBFd2dnRWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUJEd0F3Z2dFS0FvSUJBUURKNGxBOThlQVA3SGJ1emkvS1Nza1BwN0o4eUY0SEdSVzBZU0VRVWdId3dBbnlGZWVBUitZWVZRRmRnajJROU1FSGhjMGZlK25JWVpGSFNUVm8yQm8vNVJtcHN4RU9wNTB2SWNUYThIT0FtOFRvZWpsYzhMMWI4eTNnV1oyQUQ2NlVzeU5OZmJ2NEZPZlhFRGtLeXBsc1JIYkFMcVZDaWZ1T2xRMjZXTFdlTjNtQTJEZmVBbUxtWDZKQnBLejNEUE1ZS2RWdVFKWWZYUm9MWGRuNHRFQ1d0RkNOUm52ODRUMGE4bGUyZjJmRjBlNk9MN0JPSjJIcHo2R1FNakYxdTNkTGhwdmRCQVVBR0k5NkowQ1RrZVhsUDhadlZCZkNvK094alMrZXhRSitwV1NMSUU2WTJCMHEzbFNhTFRtK2JKMHd3Q042RTlMc3JxMVhzK09OdDJ4RkFnTUJBQUdqVXpCUk1CMEdBMVVkRGdRV0JCUlpPd2hVQ0hFZUxjMlVRVWN2Sm95L3hHT1J5ekFmQmdOVkhTTUVHREFXZ0JSWk93aFVDSEVlTGMyVVFVY3ZKb3kveEdPUnl6QVBCZ05WSFJNQkFmOEVCVEFEQVFIL01BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQWErekNsU3VGMzZOV2JLR1AyTXVzQS9oYjRzdWxqaWVDOEg5RU9MVm9KeGNsZ0dnMnlXbG5tMlNQZXhRRGZTTGVtUjVJazZmemhCN1gzcnRSNmZTTm9vYk5Yd3hCTHhjVG41bzYxTm5McS8vOHF3QmVTUzdreWVmRU5nTVhtL2FONEk5YjhBTGRNdjFNWTg4aSt5cHlNTVlJc21QTy9yKzg3M1NKVXNTV2w2OENjZk8wYlRMaEphWS9BdXBRZDduaEorY0Jzak1HbDlscjhGVU9zeVN1TXljUGdNTzJuemhkUlRFSG01ZWFURkI0c1lpT2FvclZLVkdVNmJ2ZkE3Q1VqdHNpNEJFb3pvcWYrNDY2ajVBb01ZVmM4YlNwYkZ6QTdsYSt4ZGZ3ZlJRTEhSVUxZRnhMK0VobVpRYnVqNitkUytGcjQwTGZzQVlTak1aR3ZLUEoyIl19.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlzcyI6Imh0dHBzOi8vbGVhZi5leGFtcGxlLmNvbSIsIl9zZF9hbGciOiJzaGEtMjU2IiwiX3NkIjpbIjN4YnVoa3R6UVZMR21rMEtrbnNMVUREQVJRNDNST2Y3YlNUWFc4OXdGVXMiXSwiTmF0aW9uYWxpdGVzIjpbeyIuLi4iOiJwZjRGTllTdVhZc0tDRFJEaXlVRmNFdGI4WHRXeWc3b2cydzhSelJFZ1lvIn0seyIuLi4iOiJtNUVZU1pRM2ZQUFhEUlJtOFVvT3IzTmJXdW1IUDNvemYzSzNkd0Zqai00In1dLCJhZHJlc3MiOnsibG9jYWxpdHkiOiJnciIsIl9zZCI6WyJFd2xqSE8teFF0N3g0UGFXcU14cl9ZOTQtYUNxZ0o3dGlxTl9TdmJIazlJIiwiV1dNS0R1bTBOcWRvZHdBSU9iaGFfSEZCWmNEanNMYmRLZTJGLUk4ODZjMCIsImJieWtDUXlYeDBBZmRrU0tfSkxfNlFDQ0hfY0hPX2lnOXdOU3AxeVNGV1EiLCJnbWZhWkF5N0xXSUgweU1LWDNmTGV1VEF1NFg5M2p4MW1wTDZFUmhvdjdJIiwibFNreWRCOEx2blhmU3FRMlZMZXlWVjFuMGgwUWJ0OHBBUjFLWkVXT0ZBayIsInRjZzNRLVdfalRzeWE0TV9pNFJEdnpjNjZjT2FHMjZkLWFmTTlOTFJWOE0iLCJ3UkkxYTY1ZE9NR3JOTzZFY0RoN0VBS0E4VDRfNGhVMzRKMnAyckRfVDFjIl19fQ.RG9UXLS6dC1ihYY9jut1a7hc4s_hOlYoAa4iwk-uFeMwz6muRvR-Hs7KyXGWSNfqmrGYHFmRWduTOH-93ZX34xA0q4P9fqOztMxbzp6Fex10NTosNpMCrNFnscsQY--4W4Dg5evQHSIiW0avzPzYvnTvMSFR7w4iigOj7WI1He_qI4YTATohT4HX26gTlDrIpuSS5iMlqLzsbjep3hA3DEc_LuFBZtDmsE3haGlIaE7Dg4GYlJH6GyHxu2HSei9T-Re-5jAPYHocXqukjgol4h8Go8wJdx-NaZ-aBcJzMtOQdzDj6sEqjQGwf6yh9jYs3CGVPYwvkwU3jltGm-E0ow~WyJSRGhCNm1YYTRvLXhtNWYzM1VKaGZnIiwiREUiXQ~
                """
  static let issuer_metadata_sd_jwt = """
                eyJhbGciOiJFUzI1NiIsImp3ayI6eyJjcnYiOiJQLTI1NiIsImt0eSI6IkVDIiwieCI6ImEtWWFNdFYyRXZ2b09TZFZKUDdsSDU5VGQ5X2N0ckN2cUlVdTI0TEVIdXMiLCJ5IjoiUEV4aGsxb3pUUFNrN2VKc1laWFZwNVNFV01iaE9nZUhaR2dCbG5GaExqYyJ9LCJraWQiOiJBbzUwU3d6dl91V3U4MDVMY3VhVFR5c3VfNkd3b3FudkpoOXJuYzQ0VTQ4IiwidHlwIjoiSldUIn0.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlzcyI6Imh0dHBzOi8vbGVhZi5leGFtcGxlLmNvbSIsIl9zZF9hbGciOiJzaGEtMjU2IiwiX3NkIjpbIjN4YnVoa3R6UVZMR21rMEtrbnNMVUREQVJRNDNST2Y3YlNUWFc4OXdGVXMiXSwiTmF0aW9uYWxpdGVzIjpbeyIuLi4iOiJwZjRGTllTdVhZc0tDRFJEaXlVRmNFdGI4WHRXeWc3b2cydzhSelJFZ1lvIn0seyIuLi4iOiJtNUVZU1pRM2ZQUFhEUlJtOFVvT3IzTmJXdW1IUDNvemYzSzNkd0Zqai00In1dLCJhZHJlc3MiOnsibG9jYWxpdHkiOiJnciIsIl9zZCI6WyJFd2xqSE8teFF0N3g0UGFXcU14cl9ZOTQtYUNxZ0o3dGlxTl9TdmJIazlJIiwiV1dNS0R1bTBOcWRvZHdBSU9iaGFfSEZCWmNEanNMYmRLZTJGLUk4ODZjMCIsImJieWtDUXlYeDBBZmRrU0tfSkxfNlFDQ0hfY0hPX2lnOXdOU3AxeVNGV1EiLCJnbWZhWkF5N0xXSUgweU1LWDNmTGV1VEF1NFg5M2p4MW1wTDZFUmhvdjdJIiwibFNreWRCOEx2blhmU3FRMlZMZXlWVjFuMGgwUWJ0OHBBUjFLWkVXT0ZBayIsInRjZzNRLVdfalRzeWE0TV9pNFJEdnpjNjZjT2FHMjZkLWFmTTlOTFJWOE0iLCJ3UkkxYTY1ZE9NR3JOTzZFY0RoN0VBS0E4VDRfNGhVMzRKMnAyckRfVDFjIl19fQ.qUqvjtwjFN36pYTEjChPo0xQ66M9GMogTYwfbddseqdhHcqNHWj_GQRdBUM5Gaf6RX3jyMNPYHsxcf15KsJX0Q~WyJSRGhCNm1YYTRvLXhtNWYzM1VKaGZnIiwiREUiXQ~
                """
  
  static let did_sd_jwt = """
                eyJhbGciOiJFUzI1NiIsImp3ayI6eyJjcnYiOiJQLTI1NiIsImt0eSI6IkVDIiwieCI6ImEtWWFNdFYyRXZ2b09TZFZKUDdsSDU5VGQ5X2N0ckN2cUlVdTI0TEVIdXMiLCJ5IjoiUEV4aGsxb3pUUFNrN2VKc1laWFZwNVNFV01iaE9nZUhaR2dCbG5GaExqYyJ9LCJraWQiOiJBbzUwU3d6dl91V3U4MDVMY3VhVFR5c3VfNkd3b3FudkpoOXJuYzQ0VTQ4IiwidHlwIjoiSldUIn0.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlzcyI6ImRpZDprZXk6bGVhZi5leGFtcGxlLmNvbSIsIl9zZF9hbGciOiJzaGEtMjU2IiwiX3NkIjpbIjN4YnVoa3R6UVZMR21rMEtrbnNMVUREQVJRNDNST2Y3YlNUWFc4OXdGVXMiXSwiTmF0aW9uYWxpdGVzIjpbeyIuLi4iOiJwZjRGTllTdVhZc0tDRFJEaXlVRmNFdGI4WHRXeWc3b2cydzhSelJFZ1lvIn0seyIuLi4iOiJtNUVZU1pRM2ZQUFhEUlJtOFVvT3IzTmJXdW1IUDNvemYzSzNkd0Zqai00In1dLCJhZHJlc3MiOnsibG9jYWxpdHkiOiJnciIsIl9zZCI6WyJFd2xqSE8teFF0N3g0UGFXcU14cl9ZOTQtYUNxZ0o3dGlxTl9TdmJIazlJIiwiV1dNS0R1bTBOcWRvZHdBSU9iaGFfSEZCWmNEanNMYmRLZTJGLUk4ODZjMCIsImJieWtDUXlYeDBBZmRrU0tfSkxfNlFDQ0hfY0hPX2lnOXdOU3AxeVNGV1EiLCJnbWZhWkF5N0xXSUgweU1LWDNmTGV1VEF1NFg5M2p4MW1wTDZFUmhvdjdJIiwibFNreWRCOEx2blhmU3FRMlZMZXlWVjFuMGgwUWJ0OHBBUjFLWkVXT0ZBayIsInRjZzNRLVdfalRzeWE0TV9pNFJEdnpjNjZjT2FHMjZkLWFmTTlOTFJWOE0iLCJ3UkkxYTY1ZE9NR3JOTzZFY0RoN0VBS0E4VDRfNGhVMzRKMnAyckRfVDFjIl19fQ._HsXhiv3PuCGHH2HpUfifJLuHb69nhB_YNgyzRmYZfZ9LkdnDHxnc8VKY-iFmbyflb0hb6XkM9P0fTuQTKsxGA~WyJSRGhCNm1YYTRvLXhtNWYzM1VKaGZnIiwiREUiXQ~
                """
  
  static let did_key = """
  {
      "crv": "P-256",
      "kid": "Ao50Swzv_uWu805LcuaTTysu_6GwoqnvJh9rnc44U48",
      "kty": "EC",
      "x": "a-YaMtV2EvvoOSdVJP7lH59Td9_ctrCvqIUu24LEHus",
      "y": "PExhk1ozTPSk7eJsYZXVp5SEWMbhOgeHZGgBlnFhLjc"
  }
  """
  
  static let presentation_sd_jwt = """
eyJhbGciOiJFUzI1NiIsImNuZiI6eyJqd2siOnsiY3J2IjoiUC0yNTYiLCJrdHkiOiJFQyIsIngiOiJSbWVCZmhsTVZjcVlJckl0VmlWRE82bVV2WTh4UVJ1UFktY3JXT095MGswIiwieSI6IlliSTRZSGwzSHU2TldZYWpaTGN1M1dfd29NZnR1NzRlR2hlbnB6cVk2X3MifX0sImtpZCI6IkFvNTBTd3p2X3VXdTgwNUxjdWFUVHlzdV82R3dvcW52Smg5cm5jNDRVNDgiLCJ0eXAiOiJKV1QifQ.eyJjbmYiOnsiandrIjp7InkiOiJZYkk0WUhsM0h1Nk5XWWFqWkxjdTNXX3dvTWZ0dTc0ZUdoZW5wenFZNl9zIiwia3R5IjoiRUMiLCJjcnYiOiJQLTI1NiIsIngiOiJSbWVCZmhsTVZjcVlJckl0VmlWRE82bVV2WTh4UVJ1UFktY3JXT095MGswIn19LCJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlzcyI6Imh0dHBzOi8vbGVhZi5leGFtcGxlLmNvbSIsIl9zZF9hbGciOiJzaGEtMjU2IiwiX3NkIjpbIjN4YnVoa3R6UVZMR21rMEtrbnNMVUREQVJRNDNST2Y3YlNUWFc4OXdGVXMiXSwiTmF0aW9uYWxpdGVzIjpbeyIuLi4iOiJwZjRGTllTdVhZc0tDRFJEaXlVRmNFdGI4WHRXeWc3b2cydzhSelJFZ1lvIn0seyIuLi4iOiJtNUVZU1pRM2ZQUFhEUlJtOFVvT3IzTmJXdW1IUDNvemYzSzNkd0Zqai00In1dLCJhZHJlc3MiOnsibG9jYWxpdHkiOiJnciIsIl9zZCI6WyJFd2xqSE8teFF0N3g0UGFXcU14cl9ZOTQtYUNxZ0o3dGlxTl9TdmJIazlJIiwiV1dNS0R1bTBOcWRvZHdBSU9iaGFfSEZCWmNEanNMYmRLZTJGLUk4ODZjMCIsImJieWtDUXlYeDBBZmRrU0tfSkxfNlFDQ0hfY0hPX2lnOXdOU3AxeVNGV1EiLCJnbWZhWkF5N0xXSUgweU1LWDNmTGV1VEF1NFg5M2p4MW1wTDZFUmhvdjdJIiwibFNreWRCOEx2blhmU3FRMlZMZXlWVjFuMGgwUWJ0OHBBUjFLWkVXT0ZBayIsInRjZzNRLVdfalRzeWE0TV9pNFJEdnpjNjZjT2FHMjZkLWFmTTlOTFJWOE0iLCJ3UkkxYTY1ZE9NR3JOTzZFY0RoN0VBS0E4VDRfNGhVMzRKMnAyckRfVDFjIl19fQ.48XmC70TpafGTy5k-VSq4CcjBeQbO_p1_j0GiLS12JNSraQ35Li2y1_kcxAYFcIOw54e8guhk_SR_N0oy0pPMg~WyJSRGhCNm1YYTRvLXhtNWYzM1VKaGZnIiwiREUiXQ~eyJhbGciOiJFUzI1NiIsInR5cCI6ImtiK2p3dCJ9.eyJub25jZSI6IjEyMzQ1Njc4OSIsImF1ZCI6ImV4YW1wbGUuY29tIiwiaWF0IjoxNzI3OTQ1ODg2LCJzZF9oYXNoIjoiTWdaUmM0bzRBWlltTGtjcmZYSEhFaU5jNm9XeFZNNDV3WnpKNkxJU0FJcyJ9.3-Nt2fgvQKSXJpg0ZpASdwD0th0qxibJHSwndjNlJ0yPfh7F6-hfQ74bHOzftx-IRBAJdAyLYnsIQkkJpzYTAQ
"""
  
  static let primary_issuer_sd_jwt = "eyJhbGciOiAiRVMyNTYiLCAidHlwIjogInZjK3NkLWp3dCIsICJ4NWMiOiBbIk1JSUM0ekNDQW1xZ0F3SUJBZ0lVY09RbklHVkdWckVVZHZ1SXhTL2lPWk1Xcm80d0NnWUlLb1pJemowRUF3SXdYREVlTUJ3R0ExVUVBd3dWVUVsRUlFbHpjM1ZsY2lCRFFTQXRJRlZVSURBeE1TMHdLd1lEVlFRS0RDUkZWVVJKSUZkaGJHeGxkQ0JTWldabGNtVnVZMlVnU1cxd2JHVnRaVzUwWVhScGIyNHhDekFKQmdOVkJBWVRBbFZVTUI0WERUSTBNVEV5T1RBeE1qazFORm9YRFRJMk1ESXlNakF4TWprMU0xb3dWREVXTUJRR0ExVUVBd3dOVUVsRUlFUlRJQzBnTURBd05qRXRNQ3NHQTFVRUNnd2tSVlZFU1NCWFlXeHNaWFFnVW1WbVpYSmxibU5sSUVsdGNHeGxiV1Z1ZEdGMGFXOXVNUXN3Q1FZRFZRUUdFd0pWVkRCWk1CTUdCeXFHU000OUFnRUdDQ3FHU000OUF3RUhBMElBQkhUYWh4dGsvRWRBQkdxK0RYMERicEp0RGt0bjl0dlJEVUJnbXVOZkVsNnBIbVdQVS9jTVpNWUZoTmpBVW9rUTNPcVFJeDdibUNOMWZRakxERHFQeVZxamdnRVFNSUlCRERBZkJnTlZIU01FR0RBV2dCU3piTGlSRnh6WHBCcG1NWWRDNFl2QVFNeVZHekFXQmdOVkhTVUJBZjhFRERBS0JnZ3JnUUlDQUFBQkFqQkRCZ05WSFI4RVBEQTZNRGlnTnFBMGhqSm9kSFJ3Y3pvdkwzQnlaWEJ5YjJRdWNHdHBMbVYxWkdsM0xtUmxkaTlqY213dmNHbGtYME5CWDFWVVh6QXhMbU55YkRBZEJnTlZIUTRFRmdRVVFlRkJWNnp4bDRQUGRxVjk4QjZrb1VoeTNSY3dEZ1lEVlIwUEFRSC9CQVFEQWdlQU1GMEdBMVVkRWdSV01GU0dVbWgwZEhCek9pOHZaMmwwYUhWaUxtTnZiUzlsZFMxa2FXZHBkR0ZzTFdsa1pXNTBhWFI1TFhkaGJHeGxkQzloY21Ob2FYUmxZM1IxY21VdFlXNWtMWEpsWm1WeVpXNWpaUzFtY21GdFpYZHZjbXN3Q2dZSUtvWkl6ajBFQXdJRFp3QXdaQUl3YjA5UkY4YTlXRXh2NjJFakdKSFNPNnY0cHlJWGxsdEhySG9VcXFyUDhRcW9qUTh5R3NkaUdwTm5WTVVpWXlDN0FqQUJ5dEpYM1JmZnFhODdCOWIrN0Qra2FQMG1BeFJjSjhCZUdGbXhMMFd5bDF6RVpaQzhaeFdqY0RJNFVrd1dQTVU9Il19.eyJfc2QiOiBbIjIwcmhRMHFRTHpaS2hmMXJEZzFVdXo4VmlubWlGV3VCeVdua1drUWRmeHciLCAiMzVWTnViWjNXZ18zbzQ4YnV2M3VGVkFwZ0hEaXVXa0t4R0xSZ0lGbk5ycyIsICJCY0JLTFBYY2FSMGJvTjlkb1I3OEVDWHVFeG50VENFbWJueHlCamE4eEFzIiwgIkpYT0tfeWpUY0w3NlNJS2xhVjRvYlYyNVhJM3ppekZrOW5lenY2dlRES2siLCAiU1BwYnVrREh6SkpWUVBid3d3Yl9WSXp3bVBjdTZKNGtyRkNKbkdleTRjVSIsICJuTGhaRHFPUXhTUmlFbDFnUXdsdkpMUGF0U29GamRCZ0c2VmVnWkpkNy00Il0sICJpc3MiOiAiaHR0cHM6Ly9jcmVkZW50aWFsLWlzc3Vlci5leGFtcGxlLmNvbSIsICJpYXQiOiAxNzM0MzA3MjAwLCAiZXhwIjogMTc0MjA4MzIwMCwgInZjdCI6ICJ1cm46ZXU6ZXVyb3BhOmVjOmV1ZGk6cGlkOjEiLCAiX3NkX2FsZyI6ICJzaGEtMjU2IiwgImNuZiI6IHsiandrIjogeyJrdHkiOiAiRUMiLCAiY3J2IjogIlAtMjU2IiwgIngiOiAiWlMxc0E5c2dvSUg3ckZ3VTFBUWl1czlhZjB3TllaLXREdzZBaFRTd0lVRSIsICJ5IjogIlBCZi1nNUJiSjlYRE5LdzJHdHhuSGxWcFFpWFVDbVBKdEc3Z2pTcjZhUGMifX19._Gk39IWxjJLU7wIo5G4Cx4hi-tI-vV-7PsFig77hp_pIfJlwGdYCHRxpC3gJBSRQieh8AViVotXU_4i27hiiFA~WyJPeGxCYmNub0FkTjdWcUNvbER0U2p3IiwgImZhbWlseV9uYW1lIiwgInRlc3QiXQ~WyJtWk54N1ZBd3ZmelRVQS1LLVU4S3RnIiwgImdpdmVuX25hbWUiLCAidGVzIl0~WyJ5ek9rN2owNm04UHBPQW1pV3YzaTNRIiwgImJpcnRoZGF0ZSIsICIyMDI0LTEyLTE1Il0~WyJOWmxTTWlycGtaQVRCeVFRRkNNUGxnIiwgImlzc3VpbmdfYXV0aG9yaXR5IiwgIlRlc3QgUElEIGlzc3VlciJd~WyJzbmduWWp1OUxBR0xMSF9JVUhTT0FRIiwgImlzc3VpbmdfY291bnRyeSIsICJGQyJd~WyI3MWFQMkpmTUtLQ0RoYm9ZaUtqdmd3IiwgIjE4IiwgZmFsc2Vd~WyJIVTRSd2NNcGxCNnVnbmFlT2l2VGVRIiwgImFnZV9lcXVhbF9vcl9vdmVyIiwgeyJfc2QiOiBbIkZnVFRqRUUyX0FadUxjaGxibjdIS3lnUGJ5QXFaMW82Q2ZSWUZ3R0Z5eEUiXX1d~"
  
  static let secondary_issuer_sd_jwt = "eyJ4NWMiOlsiTUlJRExUQ0NBcktnQXdJQkFnSVVMOHM1VHM2MzVrNk9oclJGTWxzU1JBU1lvNll3Q2dZSUtvWkl6ajBFQXdJd1hERWVNQndHQTFVRUF3d1ZVRWxFSUVsemMzVmxjaUJEUVNBdElGVlVJREF4TVMwd0t3WURWUVFLRENSRlZVUkpJRmRoYkd4bGRDQlNaV1psY21WdVkyVWdTVzF3YkdWdFpXNTBZWFJwYjI0eEN6QUpCZ05WQkFZVEFsVlVNQjRYRFRJME1URXlPVEV4TWpnek5Wb1hEVEkyTVRFeU9URXhNamd6TkZvd2FURWRNQnNHQTFVRUF3d1VSVlZFU1NCU1pXMXZkR1VnVm1WeWFXWnBaWEl4RERBS0JnTlZCQVVUQXpBd01URXRNQ3NHQTFVRUNnd2tSVlZFU1NCWFlXeHNaWFFnVW1WbVpYSmxibU5sSUVsdGNHeGxiV1Z1ZEdGMGFXOXVNUXN3Q1FZRFZRUUdFd0pWVkRCWk1CTUdCeXFHU000OUFnRUdDQ3FHU000OUF3RUhBMElBQkFXYTlVYXI3b1AxWmJHRmJzRkE0ZzMxUHpOR1pjd2gydlI3UENrazBZaUFMNGNocnNsZzljajFrQnlueVppN25acllnUE9KN3gwYXRSRmRreGZYanRDamdnRkRNSUlCUHpBTUJnTlZIUk1CQWY4RUFqQUFNQjhHQTFVZEl3UVlNQmFBRkxOc3VKRVhITmVrR21ZeGgwTGhpOEJBekpVYk1DY0dBMVVkRVFRZ01CNkNIR1JsZGk1cGMzTjFaWEl0WW1GamEyVnVaQzVsZFdScGR5NWtaWFl3RWdZRFZSMGxCQXN3Q1FZSEtJR01YUVVCQmpCREJnTlZIUjhFUERBNk1EaWdOcUEwaGpKb2RIUndjem92TDNCeVpYQnliMlF1Y0d0cExtVjFaR2wzTG1SbGRpOWpjbXd2Y0dsa1gwTkJYMVZVWHpBeExtTnliREFkQmdOVkhRNEVGZ1FVOGVIQS9NWHZreUNGNFExaW91WFAwc3BpTVVnd0RnWURWUjBQQVFIL0JBUURBZ2VBTUYwR0ExVWRFZ1JXTUZTR1VtaDBkSEJ6T2k4dloybDBhSFZpTG1OdmJTOWxkUzFrYVdkcGRHRnNMV2xrWlc1MGFYUjVMWGRoYkd4bGRDOWhjbU5vYVhSbFkzUjFjbVV0WVc1a0xYSmxabVZ5Wlc1alpTMW1jbUZ0WlhkdmNtc3dDZ1lJS29aSXpqMEVBd0lEYVFBd1pnSXhBSmpLU0EzQTdrWU9CWXdKQ09PY3JjYVJDRGVWVGZjdllZQ1I4QWp5blVpMjVJL3Rrc0RDRkE1K21hQ0xmbWtVS1FJeEFPVmpHc2dsdVF3VE41MG85N1dtaWxIYmxXNE44K3FBcm1zQkM4alRJdXRuS2ZjNHlaM3U1UTF1WllJbGJ0S1NyZz09Il0sImtpZCI6IjI3Mjg1NDYwOTcyMTEyMDczMjkzODg2ODI5ODc5OTI0NTAzNDE3NDEwMjkzODUzNCIsInR5cCI6InZjK3NkLWp3dCIsImFsZyI6IkVTMjU2In0.eyJwbGFjZV9vZl9iaXJ0aCI6eyJfc2QiOlsiMEpOZXF2d0VzNmpISFpNRnN5TEdhUXNFbS1EZHB1Z29xVS04V2hBdUlsRSIsIjh6X01JUFF5djVCSjdFM0FHV1ozR2tpTG5lR0wwYjA0dGJtb1VIZWt2amMiXX0sIl9zZCI6WyI0aUduUG9VdXl6MDRvVTdENXExR1czMjVRUHROb0pETndFWTJTa0pTOUNNIiwiOFFfMWhCQXJ4YkFBS0lhdFhOVl9zTEVzTm5SX1d1VUl5aDk0TGFDaElpMCIsIkFxZkV1U0UtVFlzZTlfNDNyUTBCN2FHZk5HVVU4ekFRZlE1S2hXdDh1YzgiLCJCNWl2cUxCUll6RDk4cjZ6dkU0Z0lSUFRldzN2ekVlb204VHRQNzZmb0ZJIiwiS0Z5aGhIZzZfcnlBMmswbWY1NFBjeFRDU2hRY2JnVFpJLWljRzJ0VDloZyIsIlNEWlVMWlJfd1RnWl9WR3RIU2JOOVBQMTFER19rZVZKQkE4NllDZnpaeEkiLCJTdXdaN21wUFVidUxTX3diYXNOb1BiQnIyakR2TVpfTElJYUtSbVZkblNJIiwiX0I0TDZ5akNMZllJU0xqQnkwVC11ai1IS0xCeWR6WEZJT2RCd0dWN1RQdyIsImFRVmljZWUwSlNyb3RGT1lIX1NkNk1QT0NtOVp4Z3lCUFVEWjZCYzAweFEiLCJiaFlYTEVCN2lsSWh1cm1DVnRCaC1jcldBUlprOWJESEgwWkR0dmR2WldZIiwiY0Y0ZzZ5TzF4R0ZfY1dpSlRsYS1MVnlHaGsxaldYOEVkMktCZU9QdHdJdyIsImlaRGJwWnQ1ZllRRG5RVE85aGFSVXlWNGpzcV9wZmZLYWFlS0RuRmxBM1kiLCJ3dEpzbk5XWDkzbnIwZ092YXV6ajJUczhHbWRFQTZBcUh0YWtJX1V3Ukl3IiwieTVyR0pIZU1TdGJhSGlnTGlDUmc5OWxnWmZVN2NvRnk5UXBjR3ZCSlBJWSJdLCJhZGRyZXNzIjp7Il9zZCI6WyI2Q3J4cXpSSENOSUdEZnVNRlcwTXFHMzJOcEVlQmNOZGtpUUUtVVAxX3BzIiwiT2ZaMzN3eGxhYkpheUtFYV9UczhQbmVTSzQ3SEY3bGwwLVpGVENEbXltYyIsIlJveTNNcHJEN0hRdVdRQXRWVFFLR3Y4NDRKbGdUSVJPeEIwbEotTFBFQWsiLCJaZ2dNU21sMmFWWC0zWjVxV3R2VktyZTFlYWlmZndjSVU0T2xSUkozMl9vIiwiY2dwN3k4THMxckV5X1M0TWZkY1ctbzJIZmZBQ0dGZTV6ZmczZEFQMG1ZWSIsIm8tY2l1clFyRTNwX3F0T09scUZoSS12ZDM2bXRaQ1pJWFg5aWR5S2xPcDQiXX0sInZjdCI6InVybjpldS5ldXJvcGEuZWMuZXVkaTpwaWQ6MSIsIl9zZF9hbGciOiJzaGEzLTI1NiIsImlzcyI6Imh0dHBzOi8vZGV2Lmlzc3Vlci1iYWNrZW5kLmV1ZGl3LmRldiIsImNuZiI6eyJqd2siOnsia3R5IjoiRUMiLCJ1c2UiOiJzaWciLCJjcnYiOiJQLTI1NiIsImtpZCI6IjRCNDNFRTEyLTQ2M0MtNDNCMy04MTU5LUIxNTQ3QjU0MzlFQSIsIngiOiJfSDhXSU9oaTZqT1JBY0o2bk5CWGU3Q3c5TnVZenVIMFJwY3huakhCVHRzIiwieSI6IlNPVWNiQy1PUUZWVTVSNWtGMjhLUDZxVTdCRWRQWWpyTkQ0S3I0R0VESmsiLCJhbGciOiJFUzI1NiJ9fSwiZXhwIjoxNzM3MDExNTczLCJpYXQiOjE3MzQ0MTk1NzMsImFnZV9lcXVhbF9vcl9vdmVyIjp7Il9zZCI6WyJXYV96eEk2OVNZWTJKS1lfZEh5WEp1S29lVm1FbmRzb0VUSzZjamlIcThJIl19fQ._LG_0nrL1yoWAQtejb7KyyQ8dpUdzeJoi9qeGRM4nJ7KP1Wj_SVaPoX1SvEhLHfSQX7x19Sz8qj2x56RMPcMiQ~WyJ4dUx5dVpEVGZXc0tKYjI0M0pqb09nIiwiZmFtaWx5X25hbWUiLCJOZWFsIl0~WyIweXVXWU9MZ2lTVGppaDU2Mm4zSGtRIiwiZ2l2ZW5fbmFtZSIsIlR5bGVyIl0~WyJXanRFM0duTWVZYVR5cUhoUHExbml3IiwiYmlydGhkYXRlIiwiMTk1NS0wNC0xMiJd~WyJDbUE4cXpYT1pBOWJ0eXN3dTc4RnlRIiwiMTgiLHRydWVd~WyJCOHFGLW41WlAxbWZPejhmQWdhLWh3IiwiYWdlX2luX3llYXJzIiw3MF0~WyJSM21RYmtBZGxTYnZfTlBjREoxWEp3IiwiYWdlX2JpcnRoX3llYXIiLCIxOTU1Il0~WyJ5NXZIWENhYmM2RHZldGluMXYxWWx3IiwiYmlydGhfZmFtaWx5X25hbWUiLCJOZWFsIl0~WyJwM21PV0tHME5wNGhmc1plZlpCQTlBIiwiYmlydGhfZ2l2ZW5fbmFtZSIsIlR5bGVyIl0~WyJCd0tZQTRSTzhoNWladG1KNWt4d0N3IiwibG9jYWxpdHkiLCIxMDEgVHJhdW5lciJd~WyJTVTFhcWtYT3dwdlVuM2FjRkZscERBIiwiY291bnRyeSIsIkFUIl0~WyJsTTN6UFI0ckNmb3BOVTlFck5vVWdBIiwiY291bnRyeSIsIkFUIl0~WyIySU1lV3BqRmdtc2ROVHVRU3lOdHRRIiwicmVnaW9uIiwiTG93ZXIgQXVzdHJpYSJd~WyJXYTgwMWRuYUk3dGRTY0FnNW1BQkRRIiwibG9jYWxpdHkiLCJHZW1laW5kZSBCaWJlcmJhY2giXQ~WyJ0RndoYW04WUl5Mzg2MXdBWFRaYnJRIiwicG9zdGFsX2NvZGUiLCIzMzMxIl0~WyItSk9UeDhOWUpqOUowX1gteURGdkJBIiwic3RyZWV0X2FkZHJlc3MiLCJUcmF1bmVyIl0~WyI4ZEpEZ1pNY0RxbVgxZDVERFdHZ0tBIiwiaG91c2VfbnVtYmVyIiwiMTAxICJd~WyI1VzdsZkVpLXMwQmZrcDQ0b0FfRzZRIiwiZ2VuZGVyIiwibWFsZSJd~WyJ3NEFCNjduMzRRTVVFZUxrUFBoMnBnIiwibmF0aW9uYWxpdGllcyIsWyJBVCJdXQ~WyJESVZaMEtWR2JVd3FORXF5R2w0MWV3IiwiaXNzdWluZ19hdXRob3JpdHkiLCJHUiBBZG1pbmlzdHJhdGl2ZSBhdXRob3JpdHkiXQ~WyJ4Y0dmekwxTDl0WUlNcEY2eUx4REdRIiwiZG9jdW1lbnRfbnVtYmVyIiwiMDc2YmQ3OWUtYTg0MS00OTg3LTllYzEtYzUxYzM0OWU0NTIwIl0~WyJYRjJtTnV0WG83bHNWNUwwX0E2aDFnIiwiYWRtaW5pc3RyYXRpdmVfbnVtYmVyIiwiZjZkMTcyMDAtMzcyNC00NGNmLWIxNjMtNDhkYjg4OTgwMTAzIl0~WyJIMEUxSXNzR3EtTkRZYWtURl9haktBIiwiaXNzdWluZ19jb3VudHJ5IiwiR1IiXQ~WyJpTGhaYWUxSFZJUlNIbnhfdlppa01RIiwiaXNzdWluZ19qdXJpc2RpY3Rpb24iLCJHUi1JIl0~"
  
  static let issuer_signed_sdjwt = """
  eyJ4NWMiOlsiTUlJRExUQ0NBcktnQXdJQkFnSVVMOHM1VHM2MzVrNk9oclJGTWxzU1JBU1lvNll3Q2dZSUtvWkl6ajBFQXdJd1hERWVNQndHQTFVRUF3d1ZVRWxFSUVsemMzVmxjaUJEUVNBdElGVlVJREF4TVMwd0t3WURWUVFLRENSRlZVUkpJRmRoYkd4bGRDQlNaV1psY21WdVkyVWdTVzF3YkdWdFpXNTBZWFJwYjI0eEN6QUpCZ05WQkFZVEFsVlVNQjRYRFRJME1URXlPVEV4TWpnek5Wb1hEVEkyTVRFeU9URXhNamd6TkZvd2FURWRNQnNHQTFVRUF3d1VSVlZFU1NCU1pXMXZkR1VnVm1WeWFXWnBaWEl4RERBS0JnTlZCQVVUQXpBd01URXRNQ3NHQTFVRUNnd2tSVlZFU1NCWFlXeHNaWFFnVW1WbVpYSmxibU5sSUVsdGNHeGxiV1Z1ZEdGMGFXOXVNUXN3Q1FZRFZRUUdFd0pWVkRCWk1CTUdCeXFHU000OUFnRUdDQ3FHU000OUF3RUhBMElBQkFXYTlVYXI3b1AxWmJHRmJzRkE0ZzMxUHpOR1pjd2gydlI3UENrazBZaUFMNGNocnNsZzljajFrQnlueVppN25acllnUE9KN3gwYXRSRmRreGZYanRDamdnRkRNSUlCUHpBTUJnTlZIUk1CQWY4RUFqQUFNQjhHQTFVZEl3UVlNQmFBRkxOc3VKRVhITmVrR21ZeGgwTGhpOEJBekpVYk1DY0dBMVVkRVFRZ01CNkNIR1JsZGk1cGMzTjFaWEl0WW1GamEyVnVaQzVsZFdScGR5NWtaWFl3RWdZRFZSMGxCQXN3Q1FZSEtJR01YUVVCQmpCREJnTlZIUjhFUERBNk1EaWdOcUEwaGpKb2RIUndjem92TDNCeVpYQnliMlF1Y0d0cExtVjFaR2wzTG1SbGRpOWpjbXd2Y0dsa1gwTkJYMVZVWHpBeExtTnliREFkQmdOVkhRNEVGZ1FVOGVIQS9NWHZreUNGNFExaW91WFAwc3BpTVVnd0RnWURWUjBQQVFIL0JBUURBZ2VBTUYwR0ExVWRFZ1JXTUZTR1VtaDBkSEJ6T2k4dloybDBhSFZpTG1OdmJTOWxkUzFrYVdkcGRHRnNMV2xrWlc1MGFYUjVMWGRoYkd4bGRDOWhjbU5vYVhSbFkzUjFjbVV0WVc1a0xYSmxabVZ5Wlc1alpTMW1jbUZ0WlhkdmNtc3dDZ1lJS29aSXpqMEVBd0lEYVFBd1pnSXhBSmpLU0EzQTdrWU9CWXdKQ09PY3JjYVJDRGVWVGZjdllZQ1I4QWp5blVpMjVJL3Rrc0RDRkE1K21hQ0xmbWtVS1FJeEFPVmpHc2dsdVF3VE41MG85N1dtaWxIYmxXNE44K3FBcm1zQkM4alRJdXRuS2ZjNHlaM3U1UTF1WllJbGJ0S1NyZz09Il0sImtpZCI6IjI3Mjg1NDYwOTcyMTEyMDczMjkzODg2ODI5ODc5OTI0NTAzNDE3NDEwMjkzODUzNCIsInR5cCI6InZjK3NkLWp3dCIsImFsZyI6IkVTMjU2In0.eyJwbGFjZV9vZl9iaXJ0aCI6eyJfc2QiOlsiQ1ZPZnBzTWdzWHZZNFZEUEptbmZvQkM1NXBBM05fQ1FYMkVlSFpteG5ybyIsIk5pVmR1R3VWalBXMU5FWjVTanQ2R1N0WEtxcDFSc0lzQW5kN2RSU1k2RU0iXX0sIl9zZCI6WyIta0xaRnkxeXhteVJUTl9rM3RyTGNjcUJrVHAwMzZsOXFEaUtTSVM1U2Y4IiwiMDhRZFZFVFdQUlJCRGN4andyRjJuM2xWbnNVTklqY0NQT192TnZhb2RzSSIsIjZEWk4xRVp0ZnFtTHVOYWc5bWRHRDBOM0o5Y3ZBc0FUYzJwTUt4dE5QTkkiLCI5OGd2dmVCa3IxYnB0SFB6b2k0UHVXR294LVZESmNZVG13aEJoVjhNQXlvIiwiSkh3dXNIUXlaZWpaTVN4d21TemVlN3kzelVFYmd3WjJwR05jX0FIZjFLayIsIlBpU2VDbWhIaDJ5LTFId2dfUDJvTGNzdDl3aV9ueG5ybjBzbHIxT0g1OTAiLCJUZHBrZlpna2I3dmhJMWxoSVZrclU1RS1QNUIxX3ZqcnNYaXVwbklkSVZrIiwiVW5SR0NHa0E2R1RTZi04ZXkzdHI0QmlOdVZFazEyLTY5bDg4aWNQdzFaMCIsIlc1WUFfMW5nRDdaRU1PZm9VdXUzTXZTbkptQnNUUXlmbzB2YmlGWkhILTgiLCJaQVFnczJWOHdDODdaVGlha1lwdnl2NG81QnlCODkzWkk5QXJjZ3pOYVM4IiwiZDY4UGMtbnZkb0tDS3VoWDVxSGtoa0lCRDZpUHlHZnA4VkxHQTc3OE4wdyIsImZWbDZjS2VuQ0g5UTFaWTNhX0RsLTZncWtNMlF5eTBpeWpfeVBkc0pQSWciLCJrS3VUa2JFbWJsWTRYX0pHWTNtZ3A4VEZfUkRKM01LdnpOZ3hTb2QyMHVFIiwidkdJNzNTS0hjRlVfQVcydUNrYXpGU3VJdjVpQ3BmcGNqSUt6aGVfY29jbyJdLCJhZGRyZXNzIjp7Il9zZCI6WyItTlRod0ZLUDMtSktBMU5tdE53YUdhVjdJWHNVLWR6bkd0MFJIYWpfaEFNIiwiT2dHUXh4eERrNjFOVm9ST1VQTFVOWkhDZEdCdlVPZ2NrT3M5Zk9MNlV1byIsImJsUE9TT1I4WGxZRF90Z2VabUw4X0p3Tk9ESW5nZ1dXQVZMVllSZ0lDQjAiLCJjeDhaeEhTbkNpSFVYZ3JzS2c4bHd5UHVic0Y0d2RpcUFjRTQtRlBGVlcwIiwiZDAySkZyenBSSThRY0M1TUdlU2VQR0NDUzhzWnQ3OVlXZ0g4R0h4OUhIbyIsInZEYVd3bDVqdi1HcUR5cGtDNkY1eU1aZHFkVElEbU5ORTB2ai1Wdno1VDgiXX0sInZjdCI6InVybjpldS5ldXJvcGEuZWMuZXVkaTpwaWQ6MSIsIl9zZF9hbGciOiJzaGEzLTI1NiIsImlzcyI6Imh0dHBzOi8vZGV2Lmlzc3Vlci1iYWNrZW5kLmV1ZGl3LmRldiIsImNuZiI6eyJqd2siOnsia3R5IjoiRUMiLCJ1c2UiOiJzaWciLCJjcnYiOiJQLTI1NiIsImtpZCI6IkRDMEM4RkY4LUEzQUQtNEUyNy1CMUY2LUE4Mjc2QjlCOEQwNiIsIngiOiJlcENjdzBTcnhlWkU0X2pOZTFEU0FyNVA3dTVydk1fU1dwZGExbVdWaEU4IiwieSI6ImxIaENSaEkyZm1VS2MxWDZVTUZqcXpydEVyY2wwd0FYcXJCdTBjZ0FJdVEiLCJhbGciOiJFUzI1NiJ9fSwiZXhwIjoxNzM5NTE2ODg3LCJpYXQiOjE3MzY5MjQ4ODcsImFnZV9lcXVhbF9vcl9vdmVyIjp7Il9zZCI6WyIxaWhKYUlGSk40ZkNNeTNkVmdkTklWeUdfZmRlYW9VdWFDS25TZEFaeWtVIl19fQ.fIssK5yvDqXSGSmeZbwYZ9TxFVZzq_5WUIlOlmz5xHDr5iWzOb9MQ6EdLsiAIObawFFi3d-kjDLaRxHgEzPJyA~WyJ2STZ5Rkk1TmZYZkxhb2RHd2o1RUpRIiwiZmFtaWx5X25hbWUiLCJOZWFsIl0~WyJUTHdYNm1CbDVQNEpFMDZaZDV3Y1FRIiwiZ2l2ZW5fbmFtZSIsIlR5bGVyIl0~WyJKbldhNWxxQ2Z5OXRnTWJvamkzczJnIiwiYmlydGhkYXRlIiwiMTk1NS0wNC0xMiJd~WyJSWnlKQmozOG9McWNldEl6QkdBN3lRIiwiMTgiLHRydWVd~WyI3SlZrVl9TUVI1Ykw2Z21vMERQb09RIiwiYWdlX2luX3llYXJzIiw3MF0~WyI2Mm1vckdscFU2YkI1NDRaRGRCVmVRIiwiYWdlX2JpcnRoX3llYXIiLCIxOTU1Il0~WyI0TDNzQUN4NWJXRWdVS204a1lsdU1BIiwiYmlydGhfZmFtaWx5X25hbWUiLCJOZWFsIl0~WyJuZkd0M3A1VHFQYTM1d0VLUUI2UXJ3IiwiYmlydGhfZ2l2ZW5fbmFtZSIsIlR5bGVyIl0~WyJfUTFwcUtVRUpxbnR3bHJZdWZaaFNnIiwibG9jYWxpdHkiLCIxMDEgVHJhdW5lciJd~WyJxRlJvYWNvWVItTXNxWmhmYVZ2QVV3IiwiY291bnRyeSIsIkFUIl0~WyJ6SXEwWkd2OWtHaVBwNXJiRjRVUXp3IiwiY291bnRyeSIsIkFUIl0~WyJWSGdwRHBzdWp0QnlMLUpmTEJLT3VnIiwicmVnaW9uIiwiTG93ZXIgQXVzdHJpYSJd~WyJLaFpPTkhHNmR2emMtdGV6M0NfTEVnIiwibG9jYWxpdHkiLCJHZW1laW5kZSBCaWJlcmJhY2giXQ~WyJvMnNLY0g2YktmZjBXaFpPQTY1MTNnIiwicG9zdGFsX2NvZGUiLCIzMzMxIl0~WyJUVVpVNmlHT2c1b1hfUEtXNEV6VlVBIiwic3RyZWV0X2FkZHJlc3MiLCJUcmF1bmVyIl0~WyJQdUpPNXIxUmxrZGpVWmZlazJWcGNnIiwiaG91c2VfbnVtYmVyIiwiMTAxICJd~WyJvVlYxWHk3WFlHRjlVN3ZtZlc0aDV3IiwiZ2VuZGVyIiwibWFsZSJd~WyJtSzBLNnM4OUVLYzBWWkJ4SUcxZWRnIiwibmF0aW9uYWxpdGllcyIsWyJBVCJdXQ~WyJqXzlmMzhFaUtlMGhKQ1hkbHhiZDlRIiwiaXNzdWluZ19hdXRob3JpdHkiLCJHUiBBZG1pbmlzdHJhdGl2ZSBhdXRob3JpdHkiXQ~WyJBZkN6SFlLZzYzakFwS3d6dTV0T1ZnIiwiZG9jdW1lbnRfbnVtYmVyIiwiOTcyMzM3OWUtMGU0Ni00MGUyLWIwNGItMDQyMWZkYzM0ZjRlIl0~WyJBOHNKeUUxRlRXcEQ1cVdmZkZ1VklnIiwiYWRtaW5pc3RyYXRpdmVfbnVtYmVyIiwiZTJiODdmMDgtYjdkYS00YmJjLWI0NjktZWQzMTA2OTg4ZTQzIl0~WyIwN2FQbWFsdldtc2VmVEFyVElRQnh3IiwiaXNzdWluZ19jb3VudHJ5IiwiR1IiXQ~WyJ6U1h6ejJseksxVVpab0w5Ql9PcVd3IiwiaXNzdWluZ19qdXJpc2RpY3Rpb24iLCJHUi1JIl0~
  """
}
