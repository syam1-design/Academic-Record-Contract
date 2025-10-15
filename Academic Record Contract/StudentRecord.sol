// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol"; 

/**
 * @title StudentRecord
 * @dev Kontrak ini adalah brankas data yang aman untuk catatan akademik seorang siswa.
 * Penulisan data dikontrol oleh alamat yang berwenang (sekolah/guru),
 * sementara data bisa dilihat oleh siapa saja (termasuk siswa).
 */
contract StudentRecord is Ownable {
    // --- State Variables ---
    uint256 public immutable studentId;
    string public studentName;
    uint8 private constant PASSING_GRADE = 75;

    // --- Data Structures ---
    struct Grade {
        uint8 score;
        uint256 lastUpdated;
        address updatedBy;
    }

    struct Achievement {
        string description;
        string proofHash; // Hash dari bukti di IPFS
        uint256 dateAchieved;
    }

    // Struct untuk mengembalikan hasil yang lebih informatif & rapi
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

    // --- Mappings & Arrays ---
    mapping(uint8 => mapping(string => Grade)) public semesterCourseGrades;
    mapping(uint8 => string[]) public coursesInSemester;
    Achievement[] public achievements;

    // --- Access Control ---
    mapping(address => bool) public isAuthorizedWriter;

    // --- Events ---
    event GradeUpdated(uint256 indexed studentId, uint8 indexed semester, string indexed course, uint8 newScore);
    event AchievementAdded(uint256 indexed studentId, string description);
    event WriterAuthorizationChanged(address indexed writer, bool isAuthorized);

    // --- Constructor ---
    constructor(uint256 _studentId, string memory _studentName, address _initialOwner) Ownable(_initialOwner) {
        studentId = _studentId;
        studentName = _studentName;
    }

    // --- Authorization Functions (Hanya untuk Pemilik: Sekolah/Admin) ---
    function addAuthorizedWriter(address _writer) public onlyOwner {
        isAuthorizedWriter[_writer] = true;
        emit WriterAuthorizationChanged(_writer, true);
    }

    function removeAuthorizedWriter(address _writer) public onlyOwner {
        isAuthorizedWriter[_writer] = false;
        emit WriterAuthorizationChanged(_writer, false);
    }

    // --- Write Functions (Hanya untuk yang Berwenang: Guru/Sekolah) ---
    modifier onlyAuthorized() {
        // Memeriksa apakah pemanggil adalah penulis yang sah ATAU pemilik kontrak.
        require(isAuthorizedWriter[msg.sender] || msg.sender == owner(), "Not an authorized writer");
        _;
    }

    function updateGrade(uint8 _semester, string memory _course, uint8 _score) public onlyAuthorized {
        require(_score <= 100, "Nilai > 100");
        require(_semester > 0, "Semester > 0");

        // Jika mata pelajaran ini baru untuk semester ini, tambahkan ke daftar.
        if (semesterCourseGrades[_semester][_course].lastUpdated == 0) {
            coursesInSemester[_semester].push(_course);
        }
        
        // Simpan atau perbarui data nilai.
        semesterCourseGrades[_semester][_course] = Grade(_score, block.timestamp, msg.sender);
        
        emit GradeUpdated(studentId, _semester, _course, _score);
    }

    function addAchievement(string memory _description, string memory _proofHash) public onlyAuthorized {
        achievements.push(Achievement(_description, _proofHash, block.timestamp));
        emit AchievementAdded(studentId, _description);
    }

    // --- View Functions (Publik, untuk dilihat siapa saja, termasuk Siswa) ---

    function getGradeDetails(uint8 _semester, string memory _course) public view returns (CourseResult memory) {
        Grade storage gradeData = semesterCourseGrades[_semester][_course];
        bool hasPassed = gradeData.score >= PASSING_GRADE;
        return CourseResult(gradeData.score, hasPassed, gradeData.lastUpdated, gradeData.updatedBy);
    }

    function getSemesterResult(uint8 _semester) public view returns (SemesterResult memory result) {
        string[] memory courses = coursesInSemester[_semester];
        result.courseCount = uint8(courses.length);

        if (result.courseCount == 0) {
            return result; // Kembalikan hasil kosong jika tidak ada nilai.
        }

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
    
    function getAllGradeDetailsInSemester(uint8 _semester) public view returns (CourseResult[] memory) {
        string[] memory courses = coursesInSemester[_semester];
        uint courseCount = courses.length;

        CourseResult[] memory allResults = new CourseResult[](courseCount);

        for (uint i = 0; i < courseCount; i++) {
            string memory currentCourse = courses[i];
            allResults[i] = getGradeDetails(_semester, currentCourse);
        }

        return allResults;
    }
}

