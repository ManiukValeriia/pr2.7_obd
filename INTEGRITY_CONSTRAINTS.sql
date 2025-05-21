BEGIN TRANSACTION;
BEGIN TRY
    -- Додаємо нову тварину
    INSERT INTO Animal (Nickname, Gender, Age, Purpose, FatherNickname, MotherNickname)
    VALUES ('Boris', 'male', 2, 'breeding', 'unknown', 'unknown');

    -- Отримуємо ID нової тварини
    DECLARE @NewAnimalID INT = SCOPE_IDENTITY();

    -- Додаємо запис про вакцинацію
    INSERT INTO Vaccination (AnimalID, VaccineName, VaccinationDate)
    VALUES (@NewAnimalID, 'Parvo', '2025-05-20');

    -- Підтверджуємо транзакцію
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    -- У разі помилки скасовуємо транзакцію
    ROLLBACK TRANSACTION;
    -- Виводимо повідомлення про помилку
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

-- Обмеження для таблиці Students
CREATE TABLE Groups (
    GroupID INT PRIMARY KEY,
    GroupName VARCHAR(50) NOT NULL
);

CREATE TABLE Students (
    StudentID INT PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Age INT CHECK (Age >= 17),
    GroupID INT,
    CONSTRAINT FK_Group FOREIGN KEY (GroupID) REFERENCES Groups(GroupID)
);

-- Обмеження для таблиці Animal
CREATE TABLE Animal (
    AnimalID INT IDENTITY(1,1) PRIMARY KEY,
    Nickname VARCHAR(50) UNIQUE NOT NULL,
    Gender CHAR(6) NOT NULL CHECK (Gender IN ('male', 'female')),
    Age INT NOT NULL,
    Purpose VARCHAR(10) NOT NULL CHECK (Purpose IN ('slaughter', 'sale', 'breeding')),
    PigletsCount INT DEFAULT NULL,
    PigletsBirthDate DATE DEFAULT NULL,
    FatherNickname VARCHAR(50) DEFAULT 'unknown',
    MotherNickname VARCHAR(50) DEFAULT 'unknown'
);

-- Негайна перевірка
CREATE TABLE Animal (
    AnimalID INT IDENTITY(1,1) PRIMARY KEY,
    Nickname VARCHAR(50) UNIQUE NOT NULL,
    Gender CHAR(6) NOT NULL CHECK (Gender IN ('male', 'female')),
    Age INT NOT NULL CHECK (Age >= 0)
);

-- Відкладена перевірка
CREATE TABLE Family (
    FamilyID INT IDENTITY(1,1) PRIMARY KEY,
    AnimalID INT NOT NULL,
    FatherID INT,
    MotherID INT,
    CONSTRAINT FK_Animal FOREIGN KEY (AnimalID) REFERENCES Animal(AnimalID),
    CONSTRAINT FK_Father FOREIGN KEY (FatherID) REFERENCES Animal(AnimalID) DEFERRABLE INITIALLY DEFERRED,
    CONSTRAINT FK_Mother FOREIGN KEY (MotherID) REFERENCES Animal(AnimalID) DEFERRABLE INITIALLY DEFERRED
);

-- Увімкнення відкладеної перевірки
SET CONSTRAINTS FK_Father, FK_Mother DEFERRED;

-- Приклад транзакції з відкладеною перевіркою
BEGIN TRANSACTION;
    INSERT INTO Animal (Nickname, Gender, Age, Purpose) VALUES ('Max', 'male', 2, 'breeding');
    DECLARE @NewAnimalID INT = SCOPE_IDENTITY();
    INSERT INTO Family (AnimalID, FatherID) VALUES (@NewAnimalID, @NewAnimalID); -- Тимчасово порушуємо
COMMIT TRANSACTION; -- Перевірка відбудеться тут

-- Негайна перевірка
CREATE TABLE Animal (
    AnimalID INT IDENTITY(1,1) PRIMARY KEY,
    Nickname VARCHAR(50) UNIQUE NOT NULL,
    Gender CHAR(6) NOT NULL CHECK (Gender IN ('male', 'female')),
    Age INT NOT NULL CHECK (Age >= 0)
);

-- Відкладена перевірка
CREATE TABLE Family (
    FamilyID INT IDENTITY(1,1) PRIMARY KEY,
    AnimalID INT NOT NULL,
    FatherID INT,
    MotherID INT,
    CONSTRAINT FK_Animal FOREIGN KEY (AnimalID) REFERENCES Animal(AnimalID),
    CONSTRAINT FK_Father FOREIGN KEY (FatherID) REFERENCES Animal(AnimalID) DEFERRABLE INITIALLY DEFERRED,
    CONSTRAINT FK_Mother FOREIGN KEY (MotherID) REFERENCES Animal(AnimalID) DEFERRABLE INITIALLY DEFERRED
);

SET CONSTRAINTS ALL DEFERRED;

-- Обмеження домена
CREATE TABLE Animal (
    AnimalID INT IDENTITY(1,1) PRIMARY KEY,
    Gender CHAR(6) NOT NULL CHECK (Gender IN ('male', 'female'))
);

-- Обмеження атрибута
ALTER TABLE Animal
ADD CONSTRAINT UK_Nickname UNIQUE (Nickname);

-- Обмеження кортежу
ALTER TABLE Animal
ADD CONSTRAINT CHK_Piglets CHECK (CASE WHEN Purpose = 'slaughter' THEN PigletsCount = 0 ELSE 1=1 END);

-- Обмеження відношення
CREATE TABLE Animal (
    AnimalID INT IDENTITY(1,1) PRIMARY KEY,
    Nickname VARCHAR(50) UNIQUE NOT NULL
);

-- Обмеження бази даних
CREATE TABLE Vaccination (
    VaccinationID INT IDENTITY(1,1) PRIMARY KEY,
    AnimalID INT NOT NULL,
    FOREIGN KEY (AnimalID) REFERENCES Animal(AnimalID) ON DELETE CASCADE
);