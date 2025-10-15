// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./StudentRecord.sol";
import "./TeacherContract.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; 

/**
 * @title SchoolAdminFactory
 * @author [Nama Anda]
 * @notice Pabrik pusat untuk menciptakan dan mengelola kontrak Siswa dan Guru.
 * @dev Dimiliki oleh Super Admin (misalnya, Kepala Sekolah atau Yayasan).
 */
contract SchoolAdminFactory is Ownable {
    // --- State Variables ---

    // Melacak alamat kontrak rapor untuk setiap ID siswa unik.
    mapping(uint256 => address) public studentIdToRecordAddress;
    // Melacak alamat kontrak alat tulis untuk setiap alamat pribadi guru.
    mapping(address => address) public teacherAddressToContract;

    // --- Events ---
    event StudentRecordCreated(uint256 indexed studentId, address indexed recordAddress, address schoolAdmin);
    event TeacherContractCreated(address indexed teacherAddress, address indexed contractAddress);
    event TeacherAuthorized(uint256 indexed studentId, address indexed teacherContractAddress);

    // --- Constructor ---
    constructor() Ownable(msg.sender) {}

    // --- Factory Functions ---

    /**
     * @notice Menciptakan sebuah brankas data baru (StudentRecord) untuk seorang siswa.
     * @dev Hanya bisa dipanggil oleh Super Admin (owner pabrik).
     * @param _studentId ID unik siswa (misalnya, NISN).
     * @param _studentName Nama lengkap siswa.
     * @param _schoolAdmin Alamat yang akan menjadi pemilik dari StudentRecord ini (misalnya, alamat admin sekolah).
     */
    function createStudentRecord(uint256 _studentId, string memory _studentName, address _schoolAdmin) public onlyOwner {
        require(studentIdToRecordAddress[_studentId] == address(0), "ID sudah ada");
        StudentRecord newRecord = new StudentRecord(_studentId, _studentName, _schoolAdmin);
        studentIdToRecordAddress[_studentId] = address(newRecord);
        emit StudentRecordCreated(_studentId, address(newRecord), _schoolAdmin);
    }

    /**
     * @notice Menciptakan sebuah alat tulis baru (TeacherContract) untuk seorang guru.
     * @dev Bisa dipanggil oleh guru itu sendiri. Kepemilikan kontrak langsung diberikan ke guru.
     */
    function createTeacherContract() public {
        require(teacherAddressToContract[msg.sender] == address(0), "Ownable");
        TeacherContract newTeacherContract = new TeacherContract();
        teacherAddressToContract[msg.sender] = address(newTeacherContract);
        emit TeacherContractCreated(msg.sender, address(newTeacherContract));
    }

    // --- Authorization Management Function ---

    /**
     * @notice Memberikan izin kepada kontrak seorang guru untuk menulis data di rapor seorang siswa.
     * @dev Hanya bisa dipanggil oleh Super Admin. Ini adalah langkah penghubung yang krusial.
     * @param _studentId ID siswa yang rapornya akan diakses.
     * @param _teacherAddress Alamat PRIBADI guru (bukan alamat kontraknya).
     */
    function authorizeTeacherForStudent(uint256 _studentId, address _teacherAddress) public onlyOwner {
        address recordAddress = studentIdToRecordAddress[_studentId];
        address teacherContractAddress = teacherAddressToContract[_teacherAddress];
        require(recordAddress != address(0), "tidak ditemukan");
        require(teacherContractAddress != address(0), "tidak ditemukan");

        // Super Admin memberi otorisasi kepada KONTRAK GURU untuk menulis di RAPOR SISWA.
        StudentRecord(recordAddress).addAuthorizedWriter(teacherContractAddress);
        emit TeacherAuthorized(_studentId, teacherContractAddress);
    }
}

