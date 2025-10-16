// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

contract StudentContract is Ownable {
    // --- State Variables ---
    uint8 private constant PASSING_GRADE = 75;
    uint256 public immutable studentId;
    string public studentName;
    address public factory;

    // PERUBAHAN: Dari satu alamat menjadi sebuah mapping untuk daftar guru.
    mapping(address => bool) public isAuthorizedTeacher;

    // ... (Structs: Grade, CourseResult, SemesterResult tidak berubah) ...

    struct Grade {
        uint8 score;
        uint256 lastUpdated;
        address updatedBy;
    }
    
    struct CourseResult {
        uint8 score;
        bool passed;
        uint256 lastUpdated;
        address updatedBy;
    }

    struct SemesterResult {
        uint16 totalScore;
        uint8 courseCount;
        uint8 averageScore;
        bool passed;
    }

    mapping(uint8 => mapping(string => Grade)) public semesterCourseGrades;
    mapping(uint8 => string[]) public coursesInSemester;

    // --- Modifier ---
    // PERUBAHAN: Modifier sekarang memeriksa apakah alamat pemanggil ada di dalam mapping.
    modifier onlyAuthorizedTeacher() {
        require(isAuthorizedTeacher[msg.sender], "Caller is not an authorized teacher contract");
        _;
    }

    // --- Events ---
    event GradeUpdated(uint256 indexed studentId, uint8 indexed semester, string indexed course, uint8 newScore);
    // PERUBAHAN: Event baru untuk otorisasi guru.
    event TeacherAuthorized(address indexed teacherContract);
    event TeacherAuthorizationRevoked(address indexed teacherContract);

    // --- Constructor ---
    constructor(uint256 _studentId, string memory _studentName, address _initialOwner) Ownable(_initialOwner) {
        studentId = _studentId;
        studentName = _studentName;
        factory = msg.sender;
    }

    // --- FUNGSI UNTUK ADMIN/FACTORY ---
    // Fungsi untuk menambah guru ke daftar otorisasi.
    function addAuthorizedTeacher(address _teacherContract) external {
        require(msg.sender == factory, "Only factory can authorize a teacher");
        require(_teacherContract != address(0), "Invalid teacher contract address");
        isAuthorizedTeacher[_teacherContract] = true;
        emit TeacherAuthorized(_teacherContract);
    }

    // PERUBAHAN: Fungsi untuk menghapus guru dari daftar otorisasi.
    function removeAuthorizedTeacher(address _teacherContract) external {
        require(msg.sender == factory, "Only factory can revoke a teacher");
        isAuthorizedTeacher[_teacherContract] = false;
        emit TeacherAuthorizationRevoked(_teacherContract);
    }

    // --- FUNGSI UNTUK KONTRAK GURU ---
  
    function updateGradeByTeacher(uint8 _semester, string memory _course, uint8 _score) external onlyAuthorizedTeacher {
        require(_score <= 100, "Nilai > 100");
        require(_semester > 0, "Semester harus > 0");

        if (semesterCourseGrades[_semester][_course].lastUpdated == 0) {
            coursesInSemester[_semester].push(_course);
        }
        
        semesterCourseGrades[_semester][_course] = Grade(_score, block.timestamp, msg.sender);
        
        emit GradeUpdated(studentId, _semester, _course, _score);
    }
    


     // --- View Functions (Publik, untuk dilihat siapa saja) --- (tergantung konteks bisa diubah) 
     //
    function getGradeDetails(uint8 _semester, string memory _course) public view returns (CourseResult memory) {
        Grade storage gradeData = semesterCourseGrades[_semester][_course];
        bool hasPassed = gradeData.score >= PASSING_GRADE;
        return CourseResult(gradeData.score, hasPassed, gradeData.lastUpdated, gradeData.updatedBy);
    }

    function getSemesterResult(uint8 _semester) public view returns (SemesterResult memory result) {
        string[] memory courses = coursesInSemester[_semester];
        result.courseCount = uint8(courses.length);
        if (result.courseCount == 0) { return result; }
        for (uint i = 0; i < courses.length; i++) {
            result.totalScore += semesterCourseGrades[_semester][courses[i]].score;
        }
        result.averageScore = uint8(result.totalScore / result.courseCount);
        result.passed = result.averageScore >= PASSING_GRADE;
        return result;
    }

    function getAllCoursesInSemester(uint8 _semester) public view returns (string[] memory) {
        return coursesInSemester[_semester];
    }
    
}







































   

