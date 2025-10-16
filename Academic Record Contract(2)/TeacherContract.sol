// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./StudentContract.sol"; // Import interface StudentContract

contract TeacherContract is Ownable {
    
    address public teacherAddress;
    string public teacherName;
    
    // --- Event ---
    event GradeSubmitted(address indexed studentContract, uint8 semester, string course, uint8 score);

    constructor(address _teacherAddress, string memory _teacherName) Ownable(_teacherAddress) {
        teacherAddress = _teacherAddress;
        teacherName = _teacherName;
    }

    /**
     * @notice Guru memanggil fungsi ini untuk mengirimkan nilai siswa.
     * @param _studentContract Alamat StudentContract milik siswa.
     * @param _semester Semester nilai.
     * @param _course Nama mata pelajaran.
     * @param _score Nilai yang diberikan.
     */
    function submitGrade(
        address _studentContract, 
        uint8 _semester, 
        string memory _course, 
        uint8 _score
    ) external onlyOwner {
        // Kontrak ini memanggil StudentContract target
        StudentContract student = StudentContract(_studentContract);
        
        // Memanggil fungsi di StudentContract
        // Alamat guru (owner) juga dikirim sebagai data tambahan jika perlu
        student.updateGradeByTeacher(_semester, _course, _score);

        emit GradeSubmitted(_studentContract, _semester, _course, _score);
    }
}