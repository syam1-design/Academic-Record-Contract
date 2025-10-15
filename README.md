# Academic Record Smart Contracts 🎓

A decentralized application (dApp) backend using Solidity smart contracts to manage academic records on the blockchain. This project demonstrates a secure and transparent system for creating student academic vaults and authorizing teachers to update grades, ensuring data integrity and controlled access.

## ✨ Key Features

-   **Factory Pattern**: A central `SchoolAdminFactory` contract is used to deploy and manage all other contracts, providing a single point of control for the school's super admin.
-   **Role-Based Access Control**: Clear separation of roles:
    -   **Super Admin**: Can create student records and authorize teacher contracts.
    -   **School Admin**: Owns a specific student's record (`StudentRecord`).
    -   **Teacher**: Owns a `TeacherContract` and can update grades only after being authorized.
-   **Secure Data Vaults**: Each student gets a dedicated `StudentRecord` contract, acting as a secure vault for their grades and achievements.
-   **Explicit Authorization**: Teachers cannot write to a student's record unless a Super Admin explicitly links their `TeacherContract` to the `StudentRecord`.

---

## 🏛️ Contract Architecture

This project consists of three main smart contracts that work together:

1.  **`SchoolAdminFactory.sol`**
    -   The main contract deployed by the super admin.
    -   **Function**: Creates `StudentRecord` and `TeacherContract` instances.
    -   **Key Method**: `authorizeTeacherForStudent()` which connects a teacher's contract to a student's record, granting write access.

2.  **`StudentRecord.sol`**
    -   A secure vault for a single student's academic data.
    -   **Function**: Stores grades, achievements, and a list of authorized writers.
    -   **Access**: Data can be read by anyone, but can only be written to by authorized addresses (teacher contracts).

3.  **`TeacherContract.sol`**
    -   A simple utility contract owned by a teacher.
    -   **Function**: Acts as a proxy for the teacher to interact with student records. The address of *this contract* is what gets authorized, not the teacher's personal address.

---

## 🛠️ Tech Stack

-   **Language**: Solidity `0.8.24`
-   **Libraries**: OpenZeppelin Contracts (for `Ownable`)

---

## 🚀 How to Use (Conceptual Steps)

1.  The **Super Admin** deploys the `SchoolAdminFactory` contract.
2.  A **Teacher** calls `createTeacherContract()` on the factory to get their own personal `TeacherContract`.
3.  The **Super Admin** calls `createStudentRecord()` for a new student, assigning a **School Admin** as its owner.
4.  The **Super Admin** calls `authorizeTeacherForStudent()`, linking the teacher's contract address to the student's record address.
5.  The **Teacher** can now call `submitGrade()` from their `TeacherContract` to update the student's grades.
