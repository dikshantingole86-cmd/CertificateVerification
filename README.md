# Certificate Verification

A blockchain-based certificate registry and verification system built using Solidity.

## Project Description

This project provides a tamper-resistant and publicly verifiable way to issue, verify, and revoke certificates using a smart contract.

Multiple authorized issuers can issue certificates, while the contract keeps a permanent history of issued and revoked certificates.

## Features

- Owner can add authorized issuers
- Owner can remove authorized issuers
- Authorized issuers can issue certificates
- Prevents duplicate certificates for the same student and workshop
- Original issuer or owner can revoke certificates
- Revocation requires a reason
- Revoked certificates are not deleted
- Anyone can verify whether a certificate is currently valid
- Student certificate history can be viewed
- Issuer certificate history can be viewed
- Certificate revocation information is stored for auditing

## Certificate Information

Each certificate stores:

- Student address
- Workshop/course name
- Certificate title
- Date
- Issuer address
- Revocation status
- Address that revoked the certificate
- Reason for revocation

## Access Control

### Owner

The owner can:

- Add issuers
- Remove issuers
- Revoke certificates

### Authorized Issuer

An authorized issuer can:

- Issue certificates
- Revoke certificates that they originally issued

### Public

Anyone can:

- Verify certificates
- View certificate history
- View certificate details
- View issuer history

## Technologies Used

- Solidity `^0.8.20`
- Ethereum
- Remix IDE
- Remix VM

## Smart Contract

The main smart contract is:

`CertificateRegistry.sol`

## Testing

The contract was tested using multiple accounts in Remix VM:

- Account 0 — Owner
- Account 1 — Issuer
- Account 2 — Issuer
- Account 3 — Student
- Account 4 — Student

## Certificate Lifecycle

```text
Issue Certificate
       ↓
     Valid
       ↓
    Revoke
       ↓
    Revoked
