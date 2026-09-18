// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CertificateRegistry {

    // Owner
    address public owner;

    // Authorized issuers
    mapping(address => bool) public authorizedIssuers;

    // Certificate structure
    struct Certificate {
        address student;
        string workshop;
        string title;
        uint256 date;
        address issuer;
        bool revoked;
        address revokedBy;
        string revocationReason;
    }

    // All certificates
    Certificate[] private certificates;

    // student -> workshop -> exists
    mapping(address => mapping(bytes32 => bool))
        private certificateExists;

    // student -> certificate IDs
    mapping(address => uint256[])
        private studentCertificates;

    // issuer -> certificate IDs
    mapping(address => uint256[])
        private issuerCertificates;


    // Events
    event IssuerAdded(address indexed issuer);
    event IssuerRemoved(address indexed issuer);

    event CertificateIssued(
        uint256 indexed certificateId,
        address indexed student,
        address indexed issuer,
        string workshop
    );

    event CertificateRevoked(
        uint256 indexed certificateId,
        address indexed revokedBy,
        string reason
    );


    // Constructor
    constructor() {
        owner = msg.sender;
    }


    // Only owner can call
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only owner"
        );
        _;
    }


    // Only authorized issuers can call
    modifier onlyIssuer() {
        require(
            authorizedIssuers[msg.sender],
            "Not authorized issuer"
        );
        _;
    }


    // Add issuer
    function addIssuer(address issuer)
        external
        onlyOwner
    {
        require(
            issuer != address(0),
            "Invalid issuer"
        );

        authorizedIssuers[issuer] = true;

        emit IssuerAdded(issuer);
    }


    // Remove issuer
    function removeIssuer(address issuer)
        external
        onlyOwner
    {
        authorizedIssuers[issuer] = false;

        emit IssuerRemoved(issuer);
    }


    // Issue certificate
    function issueCertificate(
        address student,
        string calldata workshop,
        string calldata title,
        uint256 date
    )
        external
        onlyIssuer
        returns (uint256)
    {
        require(
            student != address(0),
            "Invalid student"
        );

        bytes32 workshopKey =
            keccak256(bytes(workshop));

        require(
            !certificateExists[student][workshopKey],
            "Certificate already exists"
        );

        uint256 certificateId =
            certificates.length;

        certificates.push(
            Certificate(
                student,
                workshop,
                title,
                date,
                msg.sender,
                false,
                address(0),
                ""
            )
        );

        certificateExists[student][workshopKey] = true;

        studentCertificates[student].push(certificateId);

        issuerCertificates[msg.sender].push(certificateId);

        emit CertificateIssued(
            certificateId,
            student,
            msg.sender,
            workshop
        );

        return certificateId;
    }


    // Revoke certificate
    function revokeCertificate(
        uint256 certificateId,
        string calldata reason
    )
        external
    {
        require(
            certificateId < certificates.length,
            "Certificate does not exist"
        );

        require(
            bytes(reason).length > 0,
            "Reason required"
        );

        Certificate storage cert =
            certificates[certificateId];

        require(
            !cert.revoked,
            "Already revoked"
        );


        // Owner can revoke
        if (msg.sender == owner) {
            cert.revoked = true;
        }

        // Original issuer can revoke
        else {
            require(
                authorizedIssuers[msg.sender],
                "Not authorized"
            );

            require(
                cert.issuer == msg.sender,
                "Not original issuer"
            );

            cert.revoked = true;
        }

        cert.revokedBy = msg.sender;
        cert.revocationReason = reason;

        emit CertificateRevoked(
            certificateId,
            msg.sender,
            reason
        );
    }


    // Verify certificate
    function isValidCertificate(
        address student,
        string calldata workshop
    )
        external
        view
        returns (bool, uint256)
    {
        bytes32 workshopKey =
            keccak256(bytes(workshop));

        if (!certificateExists[student][workshopKey]) {
            return (false, 0);
        }

        uint256[] memory history =
            studentCertificates[student];

        for (uint256 i = 0; i < history.length; i++) {

            uint256 id = history[i];

            Certificate memory cert =
                certificates[id];

            if (
                keccak256(bytes(cert.workshop))
                == workshopKey
            ) {
                return (
                    !cert.revoked,
                    id
                );
            }
        }

        return (false, 0);
    }


    // Student certificate history
    function getStudentHistory(address student)
        external
        view
        returns (uint256[] memory)
    {
        return studentCertificates[student];
    }


    // Issuer certificate history
    function getIssuerHistory(address issuer)
        external
        view
        returns (uint256[] memory)
    {
        return issuerCertificates[issuer];
    }


    // Get certificate details
    function getCertificate(uint256 certificateId)
        external
        view
        returns (Certificate memory)
    {
        require(
            certificateId < certificates.length,
            "Certificate does not exist"
        );

        return certificates[certificateId];
    }


    // Number of certificates
    function getCertificateCount()
        external
        view
        returns (uint256)
    {
        return certificates.length;
    }
}