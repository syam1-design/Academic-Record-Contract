// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./StudentRecord.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; 

contract TeacherContract is Ownable {
    constructor() Ownable(msg.sender) {}

    function submitGrade(
        address _studentContractAddress,
        uint8 _semester,
        string memory _course,
        uint8 _score
    ) public onlyOwner {
        // Guru ini (sebagai pemilik kontrak) memberi perintah ke kontrak siswa.
        // Panggilan ini akan berhasil HANYA JIKA alamat TeacherContract ini
        // sudah diotorisasi di dalam StudentRecord.
        StudentRecord(_studentContractAddress).updateGrade(_semester, _course, _score);
    }
}
