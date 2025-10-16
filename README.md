# Academic Record Smart Contracts 🎓
A decentralized application (dApp) backend using Solidity smart contracts to manage academic records on the blockchain. This project demonstrates a secure and transparent system for creating student academic vaults and authorizing teachers to update grades, ensuring data integrity and controlled access.


The system is designed with a clear separation of roles between the **School Admin**, **Teacher**, and **Student** to ensure the integrity and security of academic data.



---

## 📜 Concept & Architecture

This system utilizes the **Factory Pattern**, where a primary contract (`SchoolAdminFactory`) acts as an administrative hub to create and manage all other contracts. The architecture consists of three main smart contracts that interact with each other:

1.  **`SchoolAdminFactory.sol`**
    * **Role**: The central contract controlled exclusively by the **School Admin**.
    * **Function**: Acts as a "factory" to create new `StudentContract` and `TeacherContract` instances. It manages permissions (who can grade whom) and records student achievements.

2.  **`StudentContract.sol`**
    * **Role**: Represents a "digital report card" for each student. This contract is **owned by the student** themselves.
    * **Function**: Stores all grade data per semester and course. It is designed so that grade data can only be modified by an authorized `TeacherContract`.

3.  **`TeacherContract.sol`**
    * **Role**: A digital "tool" for each teacher. This contract is **owned by the teacher**.
    * **Function**: Provides a `submitGrade` function that allows the teacher to submit grades to the relevant student's `StudentContract`.

### Data Workflow

A simple diagram of the main workflow in this system:



```
                                      ┌──────────────────────┐
                                      │     School Admin     │
                                      └──────────┬───────────┘
                                                 │ (calls)
                                      ┌──────────▼───────────┐
                                      │ SchoolAdminFactory.sol │
                                      └──────────┬───────────┘
                               (creates & manages)│
                   ┌─────────────────────────────┼─────────────────────────────┐
                   │                             │                             │
       ┌───────────▼───────────┐     ┌───────────▼───────────┐     ┌───────────▼───────────┐
       │ TeacherContract (Anne)│     │ TeacherContract (Charles) │     │ StudentContract (Bob) │
       └───────────┬───────────┘     └───────────┬───────────┘     └───────────┬───────────┘
                   │ (submits grade)             │ (submits grade)             │ (receives grade)
                   │                             │                             │
                   └─────────────────────────────┴───────────>─────────────────┘
                                    (after being authorized by Admin)
```

---

## ✨ Key Features

* **Role-Based Access Control**: Clear separation of powers between Admins, Teachers, and Students.
* **Flexible Authorization**: A student can be graded by multiple teachers, and the admin can grant or revoke permissions at any time.
* **Digital Ownership**: Students and teachers have full control over their respective contracts, ensuring digital sovereignty.
* **Achievement Logging**: Admins can add records of student achievements, with support for external proof via IPFS hashes.
* **Transparency & Immutability**: All grade records and permission changes are permanently stored and auditable on the blockchain.
* **Gas Efficient**: Designed to minimize transaction costs by avoiding data redundancy.

---

## 🛠️ Tech Stack

* **Solidity**: The primary programming language for smart contracts.
* **OpenZeppelin Contracts**: For standard, secure implementations like `Ownable`.
* **Hardhat / Truffle**: Development frameworks for compiling, testing, and deploying contracts.
* **Ethers.js / Web3.js**: JavaScript libraries for interacting with smart contracts from a front-end application.
* **IPFS (InterPlanetary File System)**: Recommended for decentralized storage of achievement proof files.

---

## 🚀 Getting Started

To run this project in a local development environment, follow these steps:

1.  **Clone the Repository**
    ```sh
    git clone [https://github.com/YOUR-URL/your-repo-name.git](https://github.com/YOUR-URL/your-repo-name.git)
    cd your-repo-name
    ```

2.  **Install Dependencies**
    ```sh
    npm install
    ```

3.  **Compile Smart Contracts**
    ```sh
    npx hardhat compile
    ```

4.  **Run Tests (Optional)**
    ```sh
    npx hardhat test
    ```

5.  **Deploy to a Network (Local or Testnet)**
    ```sh
    npx hardhat run scripts/deploy.js --network <your-network-name>
    ```

---

## 📋 Usage Workflow (As an Admin)

Once the smart contracts are deployed, here is the operational sequence for a School Admin:

1.  **Create a Student Contract**: Call `createStudentContract()` with the student's details and their wallet address as the `_studentOwnerAddress`.
2.  **Create Teacher Contracts**: Call `createTeacherContract()` for each teacher, providing their wallet address as the `_teacherAddress`.
3.  **Authorize Teachers**: Call `authorizeTeacherForStudent()` for each relevant teacher-student pair. This links the `TeacherContract` to the `StudentContract`.
4.  **Operations**: Teachers can now use the `submitGrade()` function from their respective `TeacherContract` to input grades.
5.  **Revoke Authorization (If needed)**: Call `revokeTeacherForStudent()` if a teacher no longer instructs a particular student.
6.  **Log Achievements**: Call `addAchievement()` to add records of student accomplishments.

---

## ⚠️ An Important Note on Privacy

It is crucial to remember that all data stored on a **public blockchain (like the Ethereum Mainnet or public testnets)** is **transparent**. This means anyone can view a student's grade data if they know the address of the `StudentContract`.

For applications requiring a high degree of data confidentiality, consider deploying this system on a **private blockchain** or implementing advanced privacy solutions like **Zero-Knowledge Proofs (ZKP)**.

---

## 📄 License

This project is distributed under the MIT License. See the `LICENSE` file for more details.
