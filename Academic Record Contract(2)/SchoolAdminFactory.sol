// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./StudentContract.sol";
import "./TeacherContract.sol";

contract SchoolAdminFactory is Ownable {
    
    // ... (State Variables and Structs ) ...
    mapping(uint256 => address) public studentIdToContractAddress;
    mapping(address => address) public teacherEoaToContractAddress;

    struct Achievement {
        string description;
        uint256 date;
        string proofHash;
    }
    mapping(uint256 => Achievement[]) public studentAchievements;

    event StudentContractCreated(uint256 indexed studentId, address indexed contractAddress, address indexed owner);
    event TeacherContractCreated(address indexed teacherAddress, address indexed contractAddress, string teacherName);
    event AchievementAdded(uint256 indexed studentId, string description, string proofHash);
    
    
    event TeacherAuthorizationChanged(address indexed studentContract, address indexed teacherContract, bool authorized);


    constructor() Ownable(msg.sender) {}

    // createStudentContract and createTeacherContract ...
    function createStudentContract(uint256 _studentId, string memory _studentName, address _studentOwnerAddress) external onlyOwner {
        require(studentIdToContractAddress[_studentId] == address(0), "Student ID already exists");
        
        StudentContract newStudentContract = new StudentContract(_studentId, _studentName, _studentOwnerAddress);
        studentIdToContractAddress[_studentId] = address(newStudentContract);
        
        emit StudentContractCreated(_studentId, address(newStudentContract), _studentOwnerAddress);
    }

    function createTeacherContract(address _teacherAddress, string memory _teacherName) external onlyOwner {
        require(teacherEoaToContractAddress[_teacherAddress] == address(0), "Teacher address already registered");

        TeacherContract newTeacherContract = new TeacherContract(_teacherAddress, _teacherName);
        teacherEoaToContractAddress[_teacherAddress] = address(newTeacherContract);

        emit TeacherContractCreated(_teacherAddress, address(newTeacherContract), _teacherName);
    }

    // Fungsi untuk memberi izin seorang guru untuk menilai siswa.
    function authorizeTeacherForStudent(uint256 _studentId, address _teacherEoa) external onlyOwner {
        address studentContractAddress = getStudentContractAddress(_studentId);
        address teacherContractAddress = getTeacherContractAddress(_teacherEoa);

        require(studentContractAddress != address(0), "Student contract not found");
        require(teacherContractAddress != address(0), "Teacher contract not found");

        StudentContract(studentContractAddress).addAuthorizedTeacher(teacherContractAddress);

        emit TeacherAuthorizationChanged(studentContractAddress, teacherContractAddress, true);
    }

    // Fungsi untuk mencabut izin seorang guru.
    function revokeTeacherForStudent(uint256 _studentId, address _teacherEoa) external onlyOwner {
        address studentContractAddress = getStudentContractAddress(_studentId);
        address teacherContractAddress = getTeacherContractAddress(_teacherEoa);

        require(studentContractAddress != address(0), "Student contract not found");
        require(teacherContractAddress != address(0), "Teacher contract not found");

        StudentContract(studentContractAddress).removeAuthorizedTeacher(teacherContractAddress);

        emit TeacherAuthorizationChanged(studentContractAddress, teacherContractAddress, false);
    }
    
    // ... (addAchievement and View) ...
    function addAchievement(uint256 _studentId, string memory _description, string memory _ipfsHash) external onlyOwner {
        require(studentIdToContractAddress[_studentId] != address(0), "Student ID not found");
        studentAchievements[_studentId].push(Achievement( _description, block.timestamp, _ipfsHash));
        emit AchievementAdded(_studentId, _description, _ipfsHash);
    }
    
    function getStudentContractAddress(uint256 _studentId) public view returns (address) {
        return studentIdToContractAddress[_studentId];
    }

    function getTeacherContractAddress(address _teacherEoa) public view returns (address) {
        return teacherEoaToContractAddress[_teacherEoa];
    }
    
    function getStudentAchievements(uint256 _studentId) public view returns (Achievement[] memory) {
        return studentAchievements[_studentId];
    }
}