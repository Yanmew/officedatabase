-- Criação do banco de dados para ambiente de oficina
CREATE SCHEMA office;
USE office;

-- DROP DATABASE office; -- drop database in case of adjustments needed

CREATE TABLE employees (
	employeeID INT AUTO_INCREMENT PRIMARY KEY,
    fName VARCHAR (20) NOT NULL,
    mName VARCHAR (10),
    lName VARCHAR (30) NOT NULL,
    ssn CHAR (9) NOT NULL,
    dateOfBirth DATE NOT NULL,
    email VARCHAR (40) NOT NULL,
    departmentID INT,
    phoneNumber VARCHAR (15),
    department ENUM ('HR','Finance','IT','Marketing','Sales','Operations',
					'R&D','Customer Support','Administrative Services','Legal and Compliance',
                    'QA','Project Management'),
    roleTitle VARCHAR(30),
    employeeAttendance FLOAT (3,1),
    employeePerformance FLOAT (2,1),
    employeeInTraining BOOL,
    employeeSkills VARCHAR(255),
    employeeBenefits VARCHAR(255),
    salary FLOAT(10,2),
    hireDate DATE
);

CREATE TABLE supervisors (
    supervisorID INT PRIMARY KEY,
    fName VARCHAR (20) NOT NULL,
    mName VARCHAR (10),
    lName VARCHAR (30) NOT NULL,
    department ENUM('HR', 'Finance', 'IT', 'Marketing', 'Sales', 'Operations', 'R&D', 'Customer Support', 'Administrative Services', 'Legal and Compliance', 'QA', 'Project Management')
);

-- acrescentando relação entre supervisor e empregado
ALTER TABLE employees ADD COLUMN supervisorID INT;
ALTER TABLE employees ADD CONSTRAINT fk_supervisor FOREIGN KEY (supervisorID) REFERENCES supervisors(supervisorID);

CREATE TABLE departments (
	deptID INT AUTO_INCREMENT PRIMARY KEY,
    department ENUM('HR', 'Finance', 'IT', 'Marketing', 'Sales', 'Operations', 'R&D', 'Customer Support', 'Administrative Services', 'Legal and Compliance', 'QA', 'Project Management'),
	departmentSupervisorID  INT,
    deptDescription VARCHAR(255),
    FOREIGN KEY (departmentSupervisorID) REFERENCES supervisors (supervisorID)
);

-- acrescentando relação entre departamento e empregado
ALTER TABLE employees ADD CONSTRAINT fk_department FOREIGN KEY (departmentID) REFERENCES departments(deptID);


CREATE TABLE projects (
	projectID INT AUTO_INCREMENT PRIMARY KEY,
    projectName VARCHAR (50),
    startDate DATE,
    endDate DATE,
    budget FLOAT(10,2),
    projectDescription VARCHAR(255),
    officeLocation VARCHAR(70)
);

CREATE TABLE tasks (
	taskID INT AUTO_INCREMENT PRIMARY KEY,
    taskName VARCHAR (50),
    taskDescription VARCHAR (255),
    startDate DATE,
    dueDate DATE,
    taskStatus ENUM ('Not yet started','In progress','Complete'),
    assignedEmployee INT,
    projectID INT,
    FOREIGN KEY (assignedEmployee) REFERENCES employees(employeeID),
    FOREIGN KEY (projectID) REFERENCES projects(projectID)
);

CREATE TABLE meetings (
	meetingID INT AUTO_INCREMENT PRIMARY KEY,
    meetingName VARCHAR (100),
    dateAndTime DATETIME,
    meetingLocation VARCHAR (100),
    meetingDescription VARCHAR(255),
    meetingOrganizer INT,
    FOREIGN KEY (meetingOrganizer) REFERENCES employees(employeeID)
);

CREATE TABLE clients (
	clientID INT AUTO_INCREMENT PRIMARY KEY,
    companyName VARCHAR(20),
    contactPerson VARCHAR (30) NOT NULL,
    contactEmail VARCHAR (40),
    contactPhone VARCHAR (20),
    clientAddress VARCHAR (70),
    CHECK (contactEmail IS NOT NULL OR contactPhone IS NOT NULL)
);

CREATE TABLE suppliers (
	supplierID INT AUTO_INCREMENT PRIMARY KEY,
    supplierName VARCHAR (30),
    contactPerson VARCHAR (30) NOT NULL,
    contactEmail VARCHAR (40),
    contactPhone VARCHAR (20),
    supplierAddress VARCHAR (70),
    productsProvided VARCHAR (255),
    servicesProvided VARCHAR (255),
    CHECK (productsProvided IS NOT NULL OR servicesProvided IS NOT NULL),
    CHECK (contactEmail IS NOT NULL OR contactPhone IS NOT NULL)
);

CREATE TABLE inventory (
	itemID INT AUTO_INCREMENT PRIMARY KEY,
    itemName VARCHAR (40),
    itemDescription VARCHAR (255),
    quantityInStock INT default 0,
    relatedDepartment INT,
    reorderPoint INT, -- Reestocar ao atingir este valor
    supplierID INT,
    flaggedForEvaluation BOOL, -- analise para decidir se item ainda é necessário
    FOREIGN KEY (supplierID) REFERENCES suppliers(supplierID),
    FOREIGN KEY (relatedDepartment) REFERENCES departments(deptID)
);

CREATE TABLE expenses (
	expenseID INT AUTO_INCREMENT PRIMARY KEY,
    expenseDate DATE NOT NULL,
    expenseTime TIME,
    expenseAmount FLOAT (10,2),
    expenseCategory VARCHAR (20),
    expenseDescription VARCHAR(255),
    relatedDepartment INT,
    employeeID INT NOT NULL,
    FOREIGN KEY (employeeID) REFERENCES employees(employeeID),
    FOREIGN KEY (relatedDepartment) REFERENCES departments(deptID)
);

CREATE TABLE leave_requests (
	requestID INT AUTO_INCREMENT PRIMARY KEY,
    employeeID INT,
    startDate DATE,
	endDate DATE,
    leaveRequestStatus ENUM('Rejected', 'In Analysis', 'Approved') DEFAULT 'In Analysis',
    requestReason VARCHAR(255),
    FOREIGN KEY (employeeID) REFERENCES employees(employeeID)
);

CREATE TABLE announcements (
	announcementID INT AUTO_INCREMENT PRIMARY KEY,
    announcementTitle VARCHAR (30),
    announcementDate DATE,
    announcementContent VARCHAR(255),
    announcementAuthor INT,
    targetAudience ENUM('All Employees','HR', 'Finance', 'IT', 'Marketing', 'Sales', 'Operations', 'R&D', 'Customer Support', 'Administrative Services', 'Legal and Compliance', 'QA', 'Project Management'),
	FOREIGN KEY (announcementAuthor) REFERENCES employees(employeeID)
);

CREATE TABLE equipment (
	equipmentID INT AUTO_INCREMENT PRIMARY KEY,
    equipmentName VARCHAR (20),
    equipmentDescription VARCHAR (255),
    equipmentQuantity INT default 0,
    equipmentStatus ENUM ('Unavailable','Some available','All available','In use','Under Maintenance'),
    relatedDepartment INT,
    supplierID INT,
    FOREIGN KEY (supplierID) REFERENCES suppliers(supplierID),
    FOREIGN KEY (relatedDepartment) REFERENCES departments(deptID)
);


-- INSERTS --

-- Inserting data into 'supervisors' table
INSERT INTO supervisors (supervisorID, fName, mName, lName, department)
VALUES
    (1, 'John', 'D.', 'Anderson', 'HR'),
    (2, 'Emily', 'J.', 'Williams', 'Finance'),
    (3, 'James', 'R.', 'Smith', 'IT'),
    (4, 'Sophia', 'M.', 'Johnson', 'Marketing'),
    (5, 'Oliver', 'K.', 'Davis', 'Sales'),
    (6, 'Emma', 'L.', 'Martinez', 'Operations');

-- Inserting data into 'departments' table
INSERT INTO departments (department, departmentSupervisorID, deptDescription)
VALUES
    ('HR', 1, 'Human Resources department responsible for employee management'),
    ('Finance', 2, 'Finance department responsible for financial management'),
    ('IT', 3, 'Information Technology department for IT infrastructure and support'),
    ('Marketing', 4, 'Marketing department responsible for product promotion'),
    ('Sales', 5, 'Sales department responsible for revenue generation'),
    ('Operations', 6, 'Operations department for daily business operations');

-- Inserting data into 'employees' table with matching departmentIDs and supervisorIDs
INSERT INTO employees (fName, mName, lName, ssn, dateOfBirth, email, departmentID, phoneNumber, department, roleTitle, employeeAttendance, employeePerformance, employeeInTraining, employeeSkills, employeeBenefits, salary, hireDate, supervisorID)
VALUES
    ('Sarah', 'M.', 'Johnson', '987654321', '1985-08-20', 'sarah.johnson@example.com', 1, '555-555-1111', 'HR', 'HR Assistant', 93.0, 4.1, false, 'HR Administration, Recruitment', 'Health Insurance', 45000.00, '2018-02-10', 1),
    ('Mark', 'R.', 'Williams', '567891234', '1992-04-10', 'mark.williams@example.com', 2, '555-222-3333', 'Finance', 'Financial Analyst', 98.5, 4.8, false, 'Financial Reporting, Data Analysis', 'Health Insurance, Retirement Plan', 55000.00, '2016-06-25', 2),
    ('Emily', 'K.', 'Smith', '345678912', '1989-12-05', 'emily.smith@example.com', 3, '555-444-5555', 'IT', 'Software Engineer', 92.2, 4.6, true, 'Java, Python, SQL', 'Health Insurance, Gym Membership', 70000.00, '2017-09-15', 3),
    ('Michael', 'A.', 'Davis', '123456789', '1980-07-12', 'michael.davis@example.com', 4, '555-555-7777', 'Marketing', 'Marketing Manager', 95.5, 4.3, false, 'Digital Marketing, Branding', 'Health Insurance, Stock Options', 80000.00, '2015-04-20', 4),
    ('Jennifer', 'L.', 'Martinez', '234567891', '1990-03-25', 'jennifer.martinez@example.com', 5, '555-666-8888', 'Sales', 'Sales Representative', 90.8, 4.0, true, 'Sales Prospecting, Negotiation', 'Health Insurance, Commission', 60000.00, '2019-08-10', 5),
    ('Robert', 'T.', 'Lee', '456789012', '1987-11-08', 'robert.lee@example.com', 6, '555-777-9999', 'Operations', 'Operations Manager', 96.2, 4.5, false, 'Supply Chain, Logistics', 'Health Insurance, Retirement Plan', 85000.00, '2014-02-05', 6);

-- Inserting data into 'projects' table
INSERT INTO projects (projectName, startDate, endDate, budget, projectDescription, officeLocation)
VALUES
    ('New HR Policies', '2023-01-15', '2023-05-30', 50000.00, 'Revise and implement updated HR policies', 'Headquarters, City'),
    ('Financial Analysis', '2023-03-01', '2023-06-15', 75000.00, 'Conduct financial analysis and forecasting', 'Branch Office, Town'),
    ('Website Redesign', '2023-02-10', '2023-04-30', 30000.00, 'Redesign company website for improved user experience', 'Headquarters, City');

-- Inserting data into 'tasks' table with matching assignedEmployee and projectID
INSERT INTO tasks (taskName, taskDescription, startDate, dueDate, taskStatus, assignedEmployee, projectID)
VALUES
    ('Policy Review', 'Review and update HR policies', '2023-01-20', '2023-02-10', 'In progress', 1, 1),
    ('Financial Data Collection', 'Gather financial data for analysis', '2023-03-10', '2023-03-30', 'Not yet started', 2, 2),
    ('Frontend Design', 'Design website frontend layout', '2023-02-15', '2023-03-15', 'In progress', 3, 3);

-- Inserting data into 'meetings' table with matching meetingOrganizer (employeeID)
INSERT INTO meetings (meetingName, dateAndTime, meetingLocation, meetingDescription, meetingOrganizer)
VALUES
    ('HR Team Meeting', '2023-01-25 10:00:00', 'Conference Room A', 'Monthly HR team meeting', 1),
    ('Finance Review', '2023-03-15 14:30:00', 'Boardroom', 'Financial analysis review', 2),
    ('Web Design Discussion', '2023-02-20 13:00:00', 'Meeting Room B', 'Discuss website design concepts', 3);

-- Inserting data into 'clients' table
INSERT INTO clients (companyName, contactPerson, contactEmail, contactPhone, clientAddress)
VALUES
    ('XYZ Corp', 'David Lee', 'david.lee@xyzcorp.com', '555-777-8888', '789 Maple St, City'),
    ('ABC Ltd', 'Jennifer Chen', 'jennifer.chen@abcltd.com', '555-999-0000', '456 Oak St, Town'),
    ('LMN Tech', 'Daniel Brown', 'daniel.brown@lmntech.com', '555-222-3333', '123 Elm St, City'),
    ('PQR Solutions', 'Amanda Wilson', 'amanda.wilson@pqrsolutions.com', '555-777-9999', '789 Oak St, Town');

-- Inserting data into 'suppliers' table
INSERT INTO suppliers (supplierName, contactPerson, contactEmail, contactPhone, supplierAddress, productsProvided, servicesProvided)
VALUES
    ('TechCo', 'John Smith', 'john.smith@techco.com', '555-111-2222', '789 Elm St, City', 'Computer Parts', NULL),
    ('FurniturePlus', 'Emma Johnson', 'emma.johnson@furnitureplus.com', '555-444-5555', '456 Maple St, Town', NULL, 'Furniture'),
    ('Software Solutions', 'Michael Davis', 'michael.davis@softwaresolutions.com', '555-888-9999', '789 Oak St, City', 'Software', 'Software Development Services');

-- Inserting data into 'inventory' table with matching supplierID and relatedDepartment
INSERT INTO inventory (itemName, itemDescription, quantityInStock, relatedDepartment, reorderPoint, supplierID, flaggedForEvaluation)
VALUES
    ('Laptops', 'Dell XPS 15 laptops', 30, 3, 10, 1, false),
    ('Office Chairs', 'Ergonomic office chairs', 50, 1, 20, 2, false),
    ('Printers', 'High-speed laser printers', 15, 4, 5, 1, false);

-- Inserting data into 'expenses' table with matching employeeID and relatedDepartment
INSERT INTO expenses (expenseDate, expenseTime, expenseAmount, expenseCategory, expenseDescription, relatedDepartment, employeeID)
VALUES
    ('2023-04-01', '09:30:00', 250.00, 'Office Supplies', 'Purchase of stationery', 1, 1),
    ('2023-04-05', '12:45:00', 500.00, 'Travel', 'Business trip expenses', 2, 2),
    ('2023-04-10', '15:20:00', 1000.00, 'Training', 'Employee training workshop', 3, 3);

-- Inserting data into 'leave_requests' table with matching employeeID
INSERT INTO leave_requests (employeeID, startDate, endDate, leaveRequestStatus, requestReason)
VALUES
    (1, '2023-04-15', '2023-04-20', 'Approved', 'Family vacation'),
    (2, '2023-05-10', '2023-05-15', 'In Analysis', 'Personal reasons'),
    (3, '2023-06-05', '2023-06-10', 'In Analysis', 'Medical leave');

-- Inserting data into 'announcements' table with matching announcementAuthor
INSERT INTO announcements (announcementTitle, announcementDate, announcementContent, announcementAuthor, targetAudience)
VALUES
    ('Company Picnic', '2023-04-01', 'Join us for a fun company picnic on May 15th!', 1, 'All Employees'),
    ('New Financial Report', '2023-05-05', 'The new financial report has been published in the Finance department.', 2, 'Finance'),
    ('IT Training Session', '2023-06-10', 'Upcoming IT training session on data analytics tools.', 3, 'IT');

-- Inserting data into 'equipment' table with matching supplierID and relatedDepartment
INSERT INTO equipment (equipmentName, equipmentDescription, equipmentQuantity, equipmentStatus, relatedDepartment, supplierID)
VALUES
    ('Printers', 'High-speed laser printers', 15, 'All available', 1, 1),
    ('Projectors', 'HD projectors for presentations', 5, 'Some available', 4, 2),
    ('Server Rack', 'Data center server rack', 2, 'In use', 6, 3);

-- QUERIES --

-- 1. Seleção simples com SELECT
-- Seleciona nome, sobrenome e email de todos os empregados
SELECT fName, lName, email FROM employees;

-- 2. Filtração usando WHERE
-- Seleciona detalhes dos empregados pertencentes ao departamento 'IT'
SELECT * FROM employees WHERE department = 'IT';

-- 3. Criando atributos derivados
-- Calcula o salário total (incluindo benefícios) de cada empregado, nomeando este atributo como 'totalSalary'
SELECT fName, lName, salary, employeeBenefits, salary + employeeBenefits AS totalSalary FROM employees;

-- 4. Ordenação usando ORDER BY
-- Seleciona empregados ordenados pela sua taxa de presença em ordem decrescente
SELECT fName, lName, employeeAttendance FROM employees ORDER BY employeeAttendance DESC;

-- 5. Filtrando grupos usando HAVING
-- Seleciona departamentos e a performance média dos empregados, mas incluindo apenas departamentos com performance média maior que 4.0
SELECT department, AVG(employeePerformance) AS avgPerformance
FROM employees
GROUP BY department
HAVING avgPerformance > 4.0;

-- 6. Unindo tabelas usando JOIN
-- Seleciona detalhes das tarefas, incluindo o nome,sobrenome do empregado associado e nome do projeto
SELECT t.taskName, t.taskDescription, t.taskStatus, e.fName AS assignedEmployeeFirstName, e.lName AS assignedEmployeeLastName, p.projectName
FROM tasks t
JOIN employees e ON t.assignedEmployee = e.employeeID
JOIN projects p ON t.projectID = p.projectID;

-- QUERIES EXTRAS --

-- 1. Seleciona empregados que têm salário superior a $60.000 e estão nos departamentos 'Finance' ou 'IT'
SELECT * FROM employees where salary > 60000 AND department IN ('Finance', 'IT');

-- 2. Calcula a média salarial de empregados em cada departamento, e mostra apenas departamentos com salário médio superior a $50.000
SELECT department, AVG(SALARY) AS avgSalary
FROM employees
GROUP BY department
HAVING avgSalary > 50000;

-- 3. Seleciona projectos que ainda não foram iniciados (data inicial ainda não chegou)
SELECT * FROM projects WHERE startDate > CURDATE();

-- 4. Seleciona orçamento total distribuido a cada departamento para todos os projetos atualmente em progresso (data final ainda não chegou)
SELECT d.department, SUM(p.budget) AS totalBudget
FROM departments d
JOIN projets p ON d.deptID = p.departmentID
WHERE p.endDate > CURDATE()
GROUP BY d.department;

-- 5. Seleciona todos os clientes que registraram ambos número de telefone e endereço de email
SELECT companyName, contactEmail, contactPhone
FROM clients
WHERE contactEmail IS NOT NULL and contactPhone IS NOT NULL;
