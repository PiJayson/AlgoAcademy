/*******************************************************************************
   algo.academy
   Script: install.sql
   Description: Creates and populates the algo.academy database.
   DB Server: PostgreSQL
   Authors: Radosław Myśliwiec, Michał Miziołek, Vladislav Kozulin
********************************************************************************/

CREATE EXTENSION IF NOT EXISTS citext;

/*******************************************************************************
   Create Enumerated Types
********************************************************************************/

-- CREATE TYPE DIFFICULTY AS ENUM ('Easy', 'Medium', 'Hard');

/*******************************************************************************
   Create Domains
********************************************************************************/

CREATE DOMAIN EMAIL AS CITEXT
  CHECK ( VALUE ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$' );

-- CREATE EXTENSION plperlu;
-- CREATE LANGUAGE plperlu;
--
-- CREATE FUNCTION isEmailValid(text)
--     RETURNS BOOLEAN
--     LANGUAGE plperlu
--     IMMUTABLE LEAKPROOF STRICT AS
-- $$
--     use Email::Valid;
--     my $email = shift;
--     Email::Valid->address($email) or die "Invalid email address: $email\n";
--     return 'true';
-- $$;
--
-- CREATE DOMAIN EMAIL AS TEXT NOT NULL
--     CONSTRAINT "EMAIL_Check" CHECK (isEmailValid(VALUE));

/*******************************************************************************
   Create Tables
********************************************************************************/

CREATE TABLE "Difficulty"
(
    "DifficultyId"          SERIAL              NOT NULL,
    "Name"                  TEXT                NOT NULL,

    CONSTRAINT "PK_Difficulty" PRIMARY KEY ("DifficultyId"),
    CONSTRAINT "Length_Difficulty_Name" CHECK (LENGTH("Name") <= 255)
);

CREATE TABLE "Role"
(
    "RoleId"                SERIAL              NOT NULL,
    "Name"                  TEXT                NOT NULL,

    CONSTRAINT "PK_Role" PRIMARY KEY ("RoleId"),
    CONSTRAINT "Length_Role_Name" CHECK (LENGTH("Name") <= 255)
);

CREATE TABLE "Country"
(
    "CountryId"             SERIAL              NOT NULL,
    "Name"                  TEXT                NOT NULL,

    CONSTRAINT "PK_Country" PRIMARY KEY ("CountryId"),
    CONSTRAINT "Length_Role_CountryName" CHECK (LENGTH("Name") <= 255)
);

CREATE TABLE "User"
(
    "UserId"                SERIAL              NOT NULL,
    "RoleId"                INTEGER             NOT NULL,
    "CountryId"             INTEGER             NOT NULL,
    "ProblemsSolved"        INTEGER             NOT NULL,
    "LastSolved"            TIMESTAMPTZ,
    "CreatedAt"             TIMESTAMPTZ         NOT NULL,
    "DeletedAt"             TIMESTAMPTZ,
    "Username"              TEXT                NOT NULL,
    "PasswordHash"          TEXT                NOT NULL,
    "Email"                 EMAIL               NOT NULL,
    "FirstName"             TEXT,
    "LastName"              TEXT,
    "Organization"          TEXT,
    "IsVerified"            BOOLEAN             NOT NULL,
    "NotifyMe"              BOOLEAN             NOT NULL,

    CONSTRAINT "PK_User" PRIMARY KEY ("UserId"),
    CONSTRAINT "Length_User_Username" CHECK (LENGTH("Username") <= 255),
    CONSTRAINT "Length_User_Email" CHECK (LENGTH("Email") <= 255),
    CONSTRAINT "Length_User_FirstName" CHECK (LENGTH("FirstName") <= 255),
    CONSTRAINT "Length_User_LastName" CHECK (LENGTH("LastName") <= 255),
    CONSTRAINT "Length_User_Organization" CHECK (LENGTH("Organization") <= 255),
    CONSTRAINT "Check_User_ProblemsSolved" CHECK ("ProblemsSolved" BETWEEN 0 AND 9999),
    CONSTRAINT "Check_User_CreationAndDeletion" CHECK ("DeletedAt" IS NULL OR "CreatedAt" < "DeletedAt"),
    CONSTRAINT "Check_User_Creation" CHECK ("CreatedAt" <= NOW())
);

CREATE TABLE "Contest"
(
    "ContestId"             SERIAL              NOT NULL,
    "AuthorId"              INTEGER             NOT NULL,
    "Name"                  TEXT                NOT NULL,
    "Description"           TEXT,
    "IsPublic"              BOOLEAN             NOT NULL,
    "ShowLiveRanking"       BOOLEAN             NOT NULL,
    "StartTime"             TIMESTAMPTZ         NOT NULL,
    "EndTime"               TIMESTAMPTZ         NOT NULL,

    CONSTRAINT "PK_Contest" PRIMARY KEY ("ContestId"),
    CONSTRAINT "Length_Contest_Name" CHECK (LENGTH("Name") <= 255),
    CONSTRAINT "Length_Contest_Description" CHECK (LENGTH("Description") <= 32768),
    CONSTRAINT "Check_Contest_StartAndEnd" CHECK ("StartTime" < "EndTime"),
    CONSTRAINT "Unique_Contest_Name" UNIQUE ("Name")
);

CREATE TABLE "ContestProblem"
(
    "ContestId"             INTEGER             NOT NULL,
    "ProblemId"             INTEGER             NOT NULL,

    CONSTRAINT "PK_ContestProblem" PRIMARY KEY ("ContestId", "ProblemId")
);

CREATE TABLE "ContestSubmission"
(
    "ContestId"             INTEGER             NOT NULL,
    "SubmissionId"          INTEGER             NOT NULL,

    CONSTRAINT "PK_ContestSubmission" PRIMARY KEY ("ContestId", "SubmissionId")
);

CREATE TABLE "Registration"
(
    "RegistrationId"        SERIAL              NOT NULL,
    "UserId"                INTEGER             NOT NULL,
    "ContestId"             INTEGER             NOT NULL,
    "RegisteredAt"          TIMESTAMPTZ         NOT NULL,

    CONSTRAINT "PK_Registration" PRIMARY KEY ("RegistrationId"),
    CONSTRAINT "Check_Registration_Time" CHECK ("RegisteredAt" <= NOW())
);

CREATE TABLE "ProgrammingLanguage"
(
    "ProgrammingLanguageId" SERIAL              NOT NULL,
    "Name"                  TEXT                NOT NULL,

    CONSTRAINT "PK_ProgrammingLanguage" PRIMARY KEY ("ProgrammingLanguageId"),
    CONSTRAINT "Length_ProgrammingLanguage_Name" CHECK (LENGTH("Name") <= 255)
);

CREATE TABLE "Result"
(
    "ResultId"              SERIAL              NOT NULL,
    "Name"                  TEXT                NOT NULL,

    CONSTRAINT "PK_Result" PRIMARY KEY ("ResultId"),
    CONSTRAINT "Length_Result_Name" CHECK (LENGTH("Name") <= 255)
);

CREATE TABLE "Submission"
(
    "SubmissionId"          SERIAL              NOT NULL,
    "UserId"                INTEGER             NOT NULL,
    "ProblemId"             INTEGER             NOT NULL,
    "ProgrammingLanguageId" INTEGER             NOT NULL,
    "ResultId"              INTEGER             NOT NULL,
    "Points"                INTEGER             NOT NULL,
    "SubmittedAt"           TIMESTAMPTZ         NOT NULL,
    "Code"                  TEXT                NOT NULL,

    CONSTRAINT "PK_Submission" PRIMARY KEY ("SubmissionId"),
    CONSTRAINT "Length_Submission_Code" CHECK (LENGTH("Code") <= 32768),
    CONSTRAINT "Check_Submission_Time" CHECK ("SubmittedAt" <= NOW()),
    CONSTRAINT "Check_Submission_Points" CHECK (0 <= "Points" AND "Points" <= 100)
);

CREATE TABLE "OfficialSolution"
(
    "OfficialSolutionId"    SERIAL              NOT NULL,
    "SubmissionId"          INTEGER             NOT NULL,
    "Description"           TEXT,

    CONSTRAINT "PK_OfficialSolution" PRIMARY KEY ("OfficialSolutionId"),
    CONSTRAINT "Length_OfficialSolution_Description" CHECK (LENGTH("Description") <= 32768)
);

CREATE TABLE "Source"
(
    "SourceId"              SERIAL              NOT NULL,
    "Name"                  TEXT                NOT NULL,

    CONSTRAINT "PK_Source" PRIMARY KEY ("SourceId"),
    CONSTRAINT "Length_Source_Name" CHECK (LENGTH("Name") <= 255)
);

CREATE TABLE "Problem"
(
    "ProblemId"             SERIAL              NOT NULL,
    "SourceId"              INTEGER             NOT NULL,
    "Difficulty"            INTEGER             NOT NULL,
    "Quality"               INTEGER             NOT NULL,
    "IsPublic"              BOOLEAN             NOT NULL,
    "Name"                  TEXT                NOT NULL,
    "Url"                   TEXT,
    "Path"                  TEXT,

    CONSTRAINT "PK_Problem" PRIMARY KEY ("ProblemId"),
    CONSTRAINT "Length_Problem_Path" CHECK (LENGTH("Path") <= 255),
    CONSTRAINT "Length_Problem_Name" CHECK (LENGTH("Name") <= 255),
    CONSTRAINT "Length_Problem_Url" CHECK (LENGTH("Url") <= 255),
    CONSTRAINT "Check_Problem_Quality" CHECK (0 < "Quality" AND "Quality" <= 5),
    CONSTRAINT "Check_Problem_Difficulty" CHECK (0 < "Difficulty" AND "Difficulty" <= 10)
);

CREATE TABLE "Subtask"
(
    "SubtaskId"             SERIAL              NOT NULL,
    "ProblemId"             INTEGER             NOT NULL,
    "Points"                INTEGER             NOT NULL,

    CONSTRAINT "PK_Subtask" PRIMARY KEY ("SubtaskId"),
    CONSTRAINT "Check_Subtask_Points" CHECK (0 <= "Points" AND "Points" <= 100)
);

CREATE TABLE "SubmissionTest"
(
    "SubmissionId"          INTEGER             NOT NULL,
    "TestId"                INTEGER             NOT NULL,
    "ResultId"              INTEGER             NOT NULL,
    "ExecutionTime"         NUMERIC(5, 3),
    "MemoryUsage"           INTEGER,

    CONSTRAINT "PK_SubmissionTest" PRIMARY KEY ("SubmissionId", "TestId")
);

CREATE TABLE "Test"
(
    "TestId"                SERIAL              NOT NULL,
    "SubtaskId"             INTEGER             NOT NULL,
    "ResultId"              INTEGER             NOT NULL,
    "Input"                 TEXT,
    "Output"                TEXT,
    "IsVisible"             BOOLEAN,

    CONSTRAINT "PK_Test" PRIMARY KEY ("TestId")
);

CREATE TABLE "Hint"
(
    "HintId"                SERIAL              NOT NULL,
    "ProblemId"             INTEGER             NOT NULL,
    "Priority"              INTEGER             NOT NULL,
    "Description"           TEXT                NOT NULL,

    CONSTRAINT "PK_Hint" PRIMARY KEY ("HintId"),
    CONSTRAINT "Length_Hint_Description" CHECK (LENGTH("Description") <= 32768),
    CONSTRAINT "Check_Hint_Priority" CHECK (1 <= "Priority" AND "Priority" <= 255)
);

CREATE TABLE "UserProblemHint"
(
    "UserId"                INTEGER             NOT NULL,
    "ProblemId"             INTEGER             NOT NULL,
    "VisibleHindPriority"   INTEGER             NOT NULL,

    CONSTRAINT "PK_UserProblemHint" PRIMARY KEY ("UserId", "ProblemId"),
    CONSTRAINT "Check_UserProblemHint_VisibleHintPriority" CHECK (0 <= "VisibleHindPriority" AND "VisibleHindPriority" <= 255)
);

CREATE TABLE "UserProblemsSolved"
(
    "UserId"                INTEGER             NOT NULL,
    "ProblemId"             INTEGER             NOT NULL,

    CONSTRAINT "PK_UserProblemsSolved" PRIMARY KEY ("UserId", "ProblemId")
);

CREATE TABLE "Tag"
(
    "TagId"                 SERIAL              NOT NULL,
    "Name"                  TEXT                NOT NULL,

    CONSTRAINT "PK_Tag" PRIMARY KEY ("TagId"),
    CONSTRAINT "Length_Tag_Name" CHECK (LENGTH("Name") <= 255)
);

CREATE TABLE "ProblemTag"
(
    "ProblemId"             INTEGER             NOT NULL,
    "TagId"                 INTEGER             NOT NULL,
    "DifficultyId"          INTEGER             NOT NULL,

    CONSTRAINT "PK_ProblemTag" PRIMARY KEY ("ProblemId", "TagId")
);

CREATE TABLE "TagPrerequisite"
(
    "ParentTagId"           INTEGER             NOT NULL,
    "TagId"                 INTEGER             NOT NULL,

    CONSTRAINT "PK_TagPrerequisite" PRIMARY KEY ("ParentTagId", "TagId")
);

CREATE TABLE "TagCategory"
(
    "ParentTagId"           INTEGER             NOT NULL,
    "TagId"                 INTEGER             NOT NULL,

    CONSTRAINT "PK_TagCategory" PRIMARY KEY ("ParentTagId", "TagId")
);

/*******************************************************************************
   Add table default VALUES
********************************************************************************/

ALTER TABLE ONLY "User" ALTER COLUMN "RoleId" SET DEFAULT 2;
ALTER TABLE ONLY "User" ALTER COLUMN "CountryId" SET DEFAULT NULL;
ALTER TABLE ONLY "User" ALTER COLUMN "DeletedAt" SET DEFAULT NULL;
ALTER TABLE ONLY "User" ALTER COLUMN "FirstName" SET DEFAULT NULL;
ALTER TABLE ONLY "User" ALTER COLUMN "LastName" SET DEFAULT NULL;
ALTER TABLE ONLY "User" ALTER COLUMN "Organization" SET DEFAULT NULL;
ALTER TABLE ONLY "User" ALTER COLUMN "ProblemsSolved" SET DEFAULT 0;
ALTER TABLE ONLY "User" ALTER COLUMN "NotifyMe" SET DEFAULT FALSE;
ALTER TABLE ONLY "User" ALTER COLUMN "IsVerified" SET DEFAULT FALSE;
ALTER TABLE ONLY "User" ALTER COLUMN "CreatedAt" SET DEFAULT NOW();

ALTER TABLE ONLY "Contest" ALTER COLUMN "IsPublic" SET DEFAULT FALSE;
ALTER TABLE ONLY "Contest" ALTER COLUMN "ShowLiveRanking" SET DEFAULT TRUE;
ALTER TABLE ONLY "Contest" ALTER COLUMN "Description" SET DEFAULT NULL;

ALTER TABLE ONLY "Problem" ALTER COLUMN "IsPublic" SET DEFAULT TRUE;
ALTER TABLE ONLY "Problem" ALTER COLUMN "Name" SET DEFAULT NULL;
ALTER TABLE ONLY "Problem" ALTER COLUMN "Url" SET DEFAULT NULL;
ALTER TABLE ONLY "Problem" ALTER COLUMN "Path" SET DEFAULT NULL;

ALTER TABLE ONLY "Subtask" ALTER COLUMN "Points" SET DEFAULT 0;

ALTER TABLE ONLY "SubmissionTest" ALTER COLUMN "ResultId" SET DEFAULT 7; -- ok
ALTER TABLE ONLY "SubmissionTest" ALTER COLUMN "ExecutionTime" SET DEFAULT NULL;
ALTER TABLE ONLY "SubmissionTest" ALTER COLUMN "MemoryUsage" SET DEFAULT NULL;

ALTER TABLE ONLY "Test" ALTER COLUMN "ResultId" SET DEFAULT 10; -- accepted
ALTER TABLE ONLY "Test" ALTER COLUMN "Input" SET DEFAULT NULL;
ALTER TABLE ONLY "Test" ALTER COLUMN "Output" SET DEFAULT NULL;
ALTER TABLE ONLY "Test" ALTER COLUMN "IsVisible" SET DEFAULT TRUE;

ALTER TABLE ONLY "UserProblemHint" ALTER COLUMN "VisibleHindPriority" SET DEFAULT 0;

ALTER TABLE ONLY "Registration" ALTER COLUMN "RegisteredAt" SET DEFAULT NOW();

ALTER TABLE ONLY "Submission" ALTER COLUMN "SubmittedAt" SET DEFAULT NOW();

/*******************************************************************************
   Create Foreign Keys
********************************************************************************/

ALTER TABLE "User" ADD CONSTRAINT "FK_User_RoleId"
    FOREIGN KEY ("RoleId") REFERENCES "Role" ("RoleId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "User" ADD CONSTRAINT "FK_User_CountryId"
    FOREIGN KEY ("CountryId") REFERENCES "Country" ("CountryId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "Contest" ADD CONSTRAINT "FK_Contest_AuthorId"
    FOREIGN KEY ("AuthorId") REFERENCES "User" ("UserId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "ContestProblem" ADD CONSTRAINT "FK_ContestProblem_ContestId"
    FOREIGN KEY ("ContestId") REFERENCES "Contest" ("ContestId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "ContestProblem" ADD CONSTRAINT "FK_ContestProblem_ProblemId"
    FOREIGN KEY ("ProblemId") REFERENCES "Problem" ("ProblemId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "ContestSubmission" ADD CONSTRAINT "FK_ContestSubmission_ContestId"
    FOREIGN KEY ("ContestId") REFERENCES "Contest" ("ContestId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "ContestSubmission" ADD CONSTRAINT "FK_ContestSubmission_SubmissionId"
    FOREIGN KEY ("SubmissionId") REFERENCES "Submission" ("SubmissionId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "Registration" ADD CONSTRAINT "FK_Registration_UserId"
    FOREIGN KEY ("UserId") REFERENCES "User" ("UserId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "Registration" ADD CONSTRAINT "FK_Registration_ContestId"
    FOREIGN KEY ("ContestId") REFERENCES "Contest" ("ContestId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "Submission" ADD CONSTRAINT "FK_Submission_UserId"
    FOREIGN KEY ("UserId") REFERENCES "User" ("UserId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "Submission" ADD CONSTRAINT "FK_Submission_ProblemId"
    FOREIGN KEY ("ProblemId") REFERENCES "Problem" ("ProblemId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "Submission" ADD CONSTRAINT "FK_Submission_ProgrammingLanguageId"
    FOREIGN KEY ("ProgrammingLanguageId") REFERENCES "ProgrammingLanguage" ("ProgrammingLanguageId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "Submission" ADD CONSTRAINT "FK_Submission_ResultId"
    FOREIGN KEY ("ResultId") REFERENCES "Result" ("ResultId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "OfficialSolution" ADD CONSTRAINT "FK_OfficialSolution_SubmissionId"
    FOREIGN KEY ("SubmissionId") REFERENCES "Submission" ("SubmissionId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "Problem" ADD CONSTRAINT "FK_Problem_SourceId"
    FOREIGN KEY ("SourceId") REFERENCES "Source" ("SourceId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "Subtask" ADD CONSTRAINT "FK_Subtask_ProblemId"
    FOREIGN KEY ("ProblemId") REFERENCES "Problem" ("ProblemId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "Test" ADD CONSTRAINT "FK_Test_SubtaskId"
    FOREIGN KEY ("SubtaskId") REFERENCES "Subtask" ("SubtaskId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "Test" ADD CONSTRAINT "FK_Test_ResultId"
    FOREIGN KEY ("ResultId") REFERENCES "Result" ("ResultId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "UserProblemHint" ADD CONSTRAINT "FK_UserProblemHind_UserId"
    FOREIGN KEY ("UserId") REFERENCES "User" ("UserId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "UserProblemHint" ADD CONSTRAINT "FK_UserProblemHind_ProblemId"
    FOREIGN KEY ("ProblemId") REFERENCES "Problem" ("ProblemId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "UserProblemsSolved" ADD CONSTRAINT "FK_UserProblemsSolved_UserId"
    FOREIGN KEY ("UserId") REFERENCES "User" ("UserId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "UserProblemsSolved" ADD CONSTRAINT "FK_UserProblemsSolved_ProblemId"
    FOREIGN KEY ("ProblemId") REFERENCES "Problem" ("ProblemId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "ProblemTag" ADD CONSTRAINT "FK_ProblemTag_TagId"
    FOREIGN KEY ("TagId") REFERENCES "Tag" ("TagId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "ProblemTag" ADD CONSTRAINT "FK_ProblemTag_ProblemId"
    FOREIGN KEY ("ProblemId") REFERENCES "Problem" ("ProblemId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "TagPrerequisite" ADD CONSTRAINT "FK_TagPrerequisite_ParentTagId"
    FOREIGN KEY ("ParentTagId") REFERENCES "Tag" ("TagId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "TagPrerequisite" ADD CONSTRAINT "FK_TagPrerequisite_TagId"
    FOREIGN KEY ("TagId") REFERENCES "Tag" ("TagId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "TagCategory" ADD CONSTRAINT "FK_TagCategory_ParentTagId"
    FOREIGN KEY ("ParentTagId") REFERENCES "Tag" ("TagId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "TagCategory" ADD CONSTRAINT "FK_TagCategory_TagId"
    FOREIGN KEY ("TagId") REFERENCES "Tag" ("TagId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "ProblemTag" ADD CONSTRAINT "FK_ProblemTag_DifficultyId"
    FOREIGN KEY ("DifficultyId") REFERENCES "Difficulty" ("DifficultyId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "SubmissionTest" ADD CONSTRAINT "FK_SubmissionTest_SubmissionId"
    FOREIGN KEY ("SubmissionId") REFERENCES "Submission" ("SubmissionId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "SubmissionTest" ADD CONSTRAINT "FK_SubmissionTest_TestId"
    FOREIGN KEY ("TestId") REFERENCES "Test" ("TestId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "SubmissionTest" ADD CONSTRAINT "FK_SubmissionTest_ResultId"
    FOREIGN KEY ("ResultId") REFERENCES "Result" ("ResultId") ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE "Hint" ADD CONSTRAINT "FK_Hint_ProblemId"
    FOREIGN KEY ("ProblemId") REFERENCES "Problem" ("ProblemId") ON DELETE NO ACTION ON UPDATE NO ACTION;


/*******************************************************************************
   Create Indexes
********************************************************************************/

CREATE INDEX "IFK_Contest_AuthorId" ON "User" ("UserId");

CREATE INDEX "IFK_ContestProblem_ContestId" ON "Contest" ("ContestId");

CREATE INDEX "IFK_ContestProblem_ProblemId" ON "Problem" ("ProblemId");

CREATE INDEX "IFK_ContestSubmission_ContestId" ON "Contest" ("ContestId");

CREATE INDEX "IFK_ContestSubmission_SubmissionId" ON "Submission" ("SubmissionId");

CREATE INDEX "IFK_Registration_UserId" ON "User" ("UserId");

CREATE INDEX "IFK_Registration_ContestId" ON "Contest" ("ContestId");

CREATE INDEX "IFK_Submission_UserId" ON "User" ("UserId");

CREATE INDEX "IFK_Submission_ProblemId" ON "Problem" ("ProblemId");

CREATE INDEX "IFK_Submission_ProgrammingLanguageId" ON "ProgrammingLanguage" ("ProgrammingLanguageId");

CREATE INDEX "IFK_Submission_ResultId" ON "Result" ("ResultId");

CREATE INDEX "IFK_OfficialSolution_SubmissionId" ON "Submission" ("SubmissionId");

CREATE INDEX "IFK_Problem_SourceId" ON "Source" ("SourceId");

CREATE INDEX "IFK_Subtask_ProblemId" ON "Problem" ("ProblemId");

CREATE INDEX "IFK_Test_SubtaskId" ON "Subtask" ("SubtaskId");

CREATE INDEX "IFK_Test_ResultId" ON "Result" ("ResultId");

CREATE INDEX "IFK_UserProblemHind_UserId" ON "User" ("UserId");

CREATE INDEX "IFK_UserProblemHind_ProblemId" ON "Problem" ("ProblemId");

CREATE INDEX "IFK_UserProblemsSolved_UserId" ON "User" ("UserId");

CREATE INDEX "IFK_UserProblemsSolved_ProblemId" ON "Problem" ("ProblemId");

CREATE INDEX "IFK_ProblemTag_TagId" ON "Tag" ("TagId");

CREATE INDEX "IFK_ProblemTag_ProblemId" ON "Problem" ("ProblemId");

CREATE INDEX "IFK_TagPrerequisite_ParentTagId" ON "Tag" ("TagId");

CREATE INDEX "IFK_TagPrerequisite_TagId" ON "Tag" ("TagId");

CREATE INDEX "FK_TagCategory_ParentTagId" ON "Tag" ("TagId");

CREATE INDEX "FK_TagCategory_TagId" ON "Tag" ("TagId");

CREATE INDEX "IFK_ProblemTag_DifficultyId" ON "Difficulty" ("DifficultyId");

CREATE INDEX "IFK_SubmissionTest_SubmissionId" ON "Submission" ("SubmissionId");

CREATE INDEX "IFK_SubmissionTest_TestId" ON "Test" ("TestId");

CREATE INDEX "IFK_SubmissionTest_ResultId" ON "Result" ("ResultId");

CREATE INDEX "IFK_Hint_ProblemId" ON "Problem" ("ProblemId");

/*******************************************************************************
   Insert Data Into Tables
********************************************************************************/

INSERT INTO "Difficulty" ("DifficultyId", "Name") VALUES (1, 'Easy 1');
INSERT INTO "Difficulty" ("DifficultyId", "Name") VALUES (2, 'Easy 2');
INSERT INTO "Difficulty" ("DifficultyId", "Name") VALUES (3, 'Easy 3');
INSERT INTO "Difficulty" ("DifficultyId", "Name") VALUES (4, 'Medium 1');
INSERT INTO "Difficulty" ("DifficultyId", "Name") VALUES (5, 'Medium 2');
INSERT INTO "Difficulty" ("DifficultyId", "Name") VALUES (6, 'Medium 3');
INSERT INTO "Difficulty" ("DifficultyId", "Name") VALUES (7, 'Hard 1');
INSERT INTO "Difficulty" ("DifficultyId", "Name") VALUES (8, 'Hard 2');
INSERT INTO "Difficulty" ("DifficultyId", "Name") VALUES (9, 'Hard 3');
INSERT INTO "Difficulty" ("DifficultyId", "Name") VALUES (10, 'Extreme');

INSERT INTO "ProgrammingLanguage" ("ProgrammingLanguageId", "Name") VALUES (1, 'C++');
INSERT INTO "ProgrammingLanguage" ("ProgrammingLanguageId", "Name") VALUES (2, 'C');
INSERT INTO "ProgrammingLanguage" ("ProgrammingLanguageId", "Name") VALUES (3, 'Java');
INSERT INTO "ProgrammingLanguage" ("ProgrammingLanguageId", "Name") VALUES (4, 'Python');
INSERT INTO "ProgrammingLanguage" ("ProgrammingLanguageId", "Name") VALUES (5, 'Rust');
INSERT INTO "ProgrammingLanguage" ("ProgrammingLanguageId", "Name") VALUES (6, 'C#');
INSERT INTO "ProgrammingLanguage" ("ProgrammingLanguageId", "Name") VALUES (7, 'Perl');
INSERT INTO "ProgrammingLanguage" ("ProgrammingLanguageId", "Name") VALUES (8, 'JavaScript');
INSERT INTO "ProgrammingLanguage" ("ProgrammingLanguageId", "Name") VALUES (9, 'Ruby');
INSERT INTO "ProgrammingLanguage" ("ProgrammingLanguageId", "Name") VALUES (10, 'Swift');
INSERT INTO "ProgrammingLanguage" ("ProgrammingLanguageId", "Name") VALUES (11, 'Go');
INSERT INTO "ProgrammingLanguage" ("ProgrammingLanguageId", "Name") VALUES (12, 'Scala');
INSERT INTO "ProgrammingLanguage" ("ProgrammingLanguageId", "Name") VALUES (13, 'Kotlin');
INSERT INTO "ProgrammingLanguage" ("ProgrammingLanguageId", "Name") VALUES (14, 'PHP');

INSERT INTO "Role" ("RoleId", "Name") VALUES (1, 'Admin');
INSERT INTO "Role" ("RoleId", "Name") VALUES (2, 'User');
INSERT INTO "Role" ("RoleId", "Name") VALUES (3, 'Teacher');

INSERT INTO "Result" ("ResultId", "Name") VALUES (1, 'Running');
INSERT INTO "Result" ("ResultId", "Name") VALUES (2, 'Rejected');
INSERT INTO "Result" ("ResultId", "Name") VALUES (3, 'Internal error');
INSERT INTO "Result" ("ResultId", "Name") VALUES (4, 'Compilation error');
INSERT INTO "Result" ("ResultId", "Name") VALUES (5, 'Error');
INSERT INTO "Result" ("ResultId", "Name") VALUES (6, 'Partly Ok');
INSERT INTO "Result" ("ResultId", "Name") VALUES (7, 'Ok');

INSERT INTO "Result" ("ResultId", "Name") VALUES (10, 'Accepted');
INSERT INTO "Result" ("ResultId", "Name") VALUES (11, 'Wrong answer');
INSERT INTO "Result" ("ResultId", "Name") VALUES (12, 'Runtime error');
INSERT INTO "Result" ("ResultId", "Name") VALUES (13, 'Time limit exceeded');
INSERT INTO "Result" ("ResultId", "Name") VALUES (14, 'Memory limit exceeded');

INSERT INTO "Country" ("CountryId", "Name") VALUES (1, 'Afghanistan');
INSERT INTO "Country" ("CountryId", "Name") VALUES (2, 'Åland Islands');
INSERT INTO "Country" ("CountryId", "Name") VALUES (3, 'Albania');
INSERT INTO "Country" ("CountryId", "Name") VALUES (4, 'Algeria');
INSERT INTO "Country" ("CountryId", "Name") VALUES (5, 'American Samoa');
INSERT INTO "Country" ("CountryId", "Name") VALUES (6, 'Andorra');
INSERT INTO "Country" ("CountryId", "Name") VALUES (7, 'Angola');
INSERT INTO "Country" ("CountryId", "Name") VALUES (8, 'Anguilla');
INSERT INTO "Country" ("CountryId", "Name") VALUES (9, 'Antarctica');
INSERT INTO "Country" ("CountryId", "Name") VALUES (10, 'Antigua & Barbuda');
INSERT INTO "Country" ("CountryId", "Name") VALUES (11, 'Argentina');
INSERT INTO "Country" ("CountryId", "Name") VALUES (12, 'Armenia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (13, 'Aruba');
INSERT INTO "Country" ("CountryId", "Name") VALUES (14, 'Australia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (15, 'Austria');
INSERT INTO "Country" ("CountryId", "Name") VALUES (16, 'Azerbaijan');
INSERT INTO "Country" ("CountryId", "Name") VALUES (17, 'Bahamas');
INSERT INTO "Country" ("CountryId", "Name") VALUES (18, 'Bahrain');
INSERT INTO "Country" ("CountryId", "Name") VALUES (19, 'Bangladesh');
INSERT INTO "Country" ("CountryId", "Name") VALUES (20, 'Barbados');
INSERT INTO "Country" ("CountryId", "Name") VALUES (21, 'Belarus');
INSERT INTO "Country" ("CountryId", "Name") VALUES (22, 'Belgium');
INSERT INTO "Country" ("CountryId", "Name") VALUES (23, 'Belize');
INSERT INTO "Country" ("CountryId", "Name") VALUES (24, 'Benin');
INSERT INTO "Country" ("CountryId", "Name") VALUES (25, 'Bermuda');
INSERT INTO "Country" ("CountryId", "Name") VALUES (26, 'Bhutan');
INSERT INTO "Country" ("CountryId", "Name") VALUES (27, 'Bolivia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (28, 'Bosnia & Herzegovina');
INSERT INTO "Country" ("CountryId", "Name") VALUES (29, 'Botswana');
INSERT INTO "Country" ("CountryId", "Name") VALUES (30, 'Bouvet Island');
INSERT INTO "Country" ("CountryId", "Name") VALUES (31, 'Brazil');
INSERT INTO "Country" ("CountryId", "Name") VALUES (32, 'British Indian Ocean Territory');
INSERT INTO "Country" ("CountryId", "Name") VALUES (33, 'British Virgin Islands');
INSERT INTO "Country" ("CountryId", "Name") VALUES (34, 'Brunei');
INSERT INTO "Country" ("CountryId", "Name") VALUES (35, 'Bulgaria');
INSERT INTO "Country" ("CountryId", "Name") VALUES (36, 'Burkina Faso');
INSERT INTO "Country" ("CountryId", "Name") VALUES (37, 'Burundi');
INSERT INTO "Country" ("CountryId", "Name") VALUES (38, 'Cambodia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (39, 'Cameroon');
INSERT INTO "Country" ("CountryId", "Name") VALUES (40, 'Canada');
INSERT INTO "Country" ("CountryId", "Name") VALUES (41, 'Cape Verde');
INSERT INTO "Country" ("CountryId", "Name") VALUES (42, 'Caribbean Netherlands');
INSERT INTO "Country" ("CountryId", "Name") VALUES (43, 'Cayman Islands');
INSERT INTO "Country" ("CountryId", "Name") VALUES (44, 'Central African Republic');
INSERT INTO "Country" ("CountryId", "Name") VALUES (45, 'Chad');
INSERT INTO "Country" ("CountryId", "Name") VALUES (46, 'Chile');
INSERT INTO "Country" ("CountryId", "Name") VALUES (47, 'China');
INSERT INTO "Country" ("CountryId", "Name") VALUES (48, 'Christmas Island');
INSERT INTO "Country" ("CountryId", "Name") VALUES (49, 'Cocos (Keeling) Islands');
INSERT INTO "Country" ("CountryId", "Name") VALUES (50, 'Colombia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (51, 'Comoros');
INSERT INTO "Country" ("CountryId", "Name") VALUES (52, 'Congo - Brazzaville');
INSERT INTO "Country" ("CountryId", "Name") VALUES (53, 'Congo - Kinshasa');
INSERT INTO "Country" ("CountryId", "Name") VALUES (54, 'Cook Islands');
INSERT INTO "Country" ("CountryId", "Name") VALUES (55, 'Costa Rica');
INSERT INTO "Country" ("CountryId", "Name") VALUES (56, 'Côte d’Ivoire');
INSERT INTO "Country" ("CountryId", "Name") VALUES (57, 'Croatia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (58, 'Cuba');
INSERT INTO "Country" ("CountryId", "Name") VALUES (59, 'Curaçao');
INSERT INTO "Country" ("CountryId", "Name") VALUES (60, 'Cyprus');
INSERT INTO "Country" ("CountryId", "Name") VALUES (61, 'Czechia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (62, 'Denmark');
INSERT INTO "Country" ("CountryId", "Name") VALUES (63, 'Djibouti');
INSERT INTO "Country" ("CountryId", "Name") VALUES (64, 'Dominica');
INSERT INTO "Country" ("CountryId", "Name") VALUES (65, 'Dominican Republic');
INSERT INTO "Country" ("CountryId", "Name") VALUES (66, 'Ecuador');
INSERT INTO "Country" ("CountryId", "Name") VALUES (67, 'Egypt');
INSERT INTO "Country" ("CountryId", "Name") VALUES (68, 'El Salvador');
INSERT INTO "Country" ("CountryId", "Name") VALUES (69, 'Equatorial Guinea');
INSERT INTO "Country" ("CountryId", "Name") VALUES (70, 'Eritrea');
INSERT INTO "Country" ("CountryId", "Name") VALUES (71, 'Estonia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (72, 'Eswatini');
INSERT INTO "Country" ("CountryId", "Name") VALUES (73, 'Ethiopia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (74, 'Falkland Islands');
INSERT INTO "Country" ("CountryId", "Name") VALUES (75, 'Faroe Islands');
INSERT INTO "Country" ("CountryId", "Name") VALUES (76, 'Fiji');
INSERT INTO "Country" ("CountryId", "Name") VALUES (77, 'Finland');
INSERT INTO "Country" ("CountryId", "Name") VALUES (78, 'France');
INSERT INTO "Country" ("CountryId", "Name") VALUES (79, 'French Guiana');
INSERT INTO "Country" ("CountryId", "Name") VALUES (80, 'French Polynesia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (81, 'French Southern Territories');
INSERT INTO "Country" ("CountryId", "Name") VALUES (82, 'Gabon');
INSERT INTO "Country" ("CountryId", "Name") VALUES (83, 'Gambia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (84, 'Georgia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (85, 'Germany');
INSERT INTO "Country" ("CountryId", "Name") VALUES (86, 'Ghana');
INSERT INTO "Country" ("CountryId", "Name") VALUES (87, 'Gibraltar');
INSERT INTO "Country" ("CountryId", "Name") VALUES (88, 'Greece');
INSERT INTO "Country" ("CountryId", "Name") VALUES (89, 'Greenland');
INSERT INTO "Country" ("CountryId", "Name") VALUES (90, 'Grenada');
INSERT INTO "Country" ("CountryId", "Name") VALUES (91, 'Guadeloupe');
INSERT INTO "Country" ("CountryId", "Name") VALUES (92, 'Guam');
INSERT INTO "Country" ("CountryId", "Name") VALUES (93, 'Guatemala');
INSERT INTO "Country" ("CountryId", "Name") VALUES (94, 'Guernsey');
INSERT INTO "Country" ("CountryId", "Name") VALUES (95, 'Guinea');
INSERT INTO "Country" ("CountryId", "Name") VALUES (96, 'Guinea-Bissau');
INSERT INTO "Country" ("CountryId", "Name") VALUES (97, 'Guyana');
INSERT INTO "Country" ("CountryId", "Name") VALUES (98, 'Haiti');
INSERT INTO "Country" ("CountryId", "Name") VALUES (99, 'Heard & McDonald Islands');
INSERT INTO "Country" ("CountryId", "Name") VALUES (100, 'Honduras');
INSERT INTO "Country" ("CountryId", "Name") VALUES (101, 'Hong Kong SAR China');
INSERT INTO "Country" ("CountryId", "Name") VALUES (102, 'Hungary');
INSERT INTO "Country" ("CountryId", "Name") VALUES (103, 'Iceland');
INSERT INTO "Country" ("CountryId", "Name") VALUES (104, 'India');
INSERT INTO "Country" ("CountryId", "Name") VALUES (105, 'Indonesia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (106, 'Iran');
INSERT INTO "Country" ("CountryId", "Name") VALUES (107, 'Iraq');
INSERT INTO "Country" ("CountryId", "Name") VALUES (108, 'Ireland');
INSERT INTO "Country" ("CountryId", "Name") VALUES (109, 'Isle of Man');
INSERT INTO "Country" ("CountryId", "Name") VALUES (110, 'Israel');
INSERT INTO "Country" ("CountryId", "Name") VALUES (111, 'Italy');
INSERT INTO "Country" ("CountryId", "Name") VALUES (112, 'Jamaica');
INSERT INTO "Country" ("CountryId", "Name") VALUES (113, 'Japan');
INSERT INTO "Country" ("CountryId", "Name") VALUES (114, 'Jersey');
INSERT INTO "Country" ("CountryId", "Name") VALUES (115, 'Jordan');
INSERT INTO "Country" ("CountryId", "Name") VALUES (116, 'Kazakhstan');
INSERT INTO "Country" ("CountryId", "Name") VALUES (117, 'Kenya');
INSERT INTO "Country" ("CountryId", "Name") VALUES (118, 'Kiribati');
INSERT INTO "Country" ("CountryId", "Name") VALUES (119, 'Kuwait');
INSERT INTO "Country" ("CountryId", "Name") VALUES (120, 'Kyrgyzstan');
INSERT INTO "Country" ("CountryId", "Name") VALUES (121, 'Laos');
INSERT INTO "Country" ("CountryId", "Name") VALUES (122, 'Latvia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (123, 'Lebanon');
INSERT INTO "Country" ("CountryId", "Name") VALUES (124, 'Lesotho');
INSERT INTO "Country" ("CountryId", "Name") VALUES (125, 'Liberia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (126, 'Libya');
INSERT INTO "Country" ("CountryId", "Name") VALUES (127, 'Liechtenstein');
INSERT INTO "Country" ("CountryId", "Name") VALUES (128, 'Lithuania');
INSERT INTO "Country" ("CountryId", "Name") VALUES (129, 'Luxembourg');
INSERT INTO "Country" ("CountryId", "Name") VALUES (130, 'Macao SAR China');
INSERT INTO "Country" ("CountryId", "Name") VALUES (131, 'Madagascar');
INSERT INTO "Country" ("CountryId", "Name") VALUES (132, 'Malawi');
INSERT INTO "Country" ("CountryId", "Name") VALUES (133, 'Malaysia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (134, 'Maldives');
INSERT INTO "Country" ("CountryId", "Name") VALUES (135, 'Mali');
INSERT INTO "Country" ("CountryId", "Name") VALUES (136, 'Malta');
INSERT INTO "Country" ("CountryId", "Name") VALUES (137, 'Marshall Islands');
INSERT INTO "Country" ("CountryId", "Name") VALUES (138, 'Martinique');
INSERT INTO "Country" ("CountryId", "Name") VALUES (139, 'Mauritania');
INSERT INTO "Country" ("CountryId", "Name") VALUES (140, 'Mauritius');
INSERT INTO "Country" ("CountryId", "Name") VALUES (141, 'Mayotte');
INSERT INTO "Country" ("CountryId", "Name") VALUES (142, 'Mexico');
INSERT INTO "Country" ("CountryId", "Name") VALUES (143, 'Micronesia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (144, 'Moldova');
INSERT INTO "Country" ("CountryId", "Name") VALUES (145, 'Monaco');
INSERT INTO "Country" ("CountryId", "Name") VALUES (146, 'Mongolia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (147, 'Montenegro');
INSERT INTO "Country" ("CountryId", "Name") VALUES (148, 'Montserrat');
INSERT INTO "Country" ("CountryId", "Name") VALUES (149, 'Morocco');
INSERT INTO "Country" ("CountryId", "Name") VALUES (150, 'Mozambique');
INSERT INTO "Country" ("CountryId", "Name") VALUES (151, 'Myanmar (Burma)');
INSERT INTO "Country" ("CountryId", "Name") VALUES (152, 'Namibia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (153, 'Nauru');
INSERT INTO "Country" ("CountryId", "Name") VALUES (154, 'Nepal');
INSERT INTO "Country" ("CountryId", "Name") VALUES (155, 'Netherlands');
INSERT INTO "Country" ("CountryId", "Name") VALUES (156, 'New Caledonia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (157, 'New Zealand');
INSERT INTO "Country" ("CountryId", "Name") VALUES (158, 'Nicaragua');
INSERT INTO "Country" ("CountryId", "Name") VALUES (159, 'Niger');
INSERT INTO "Country" ("CountryId", "Name") VALUES (160, 'Nigeria');
INSERT INTO "Country" ("CountryId", "Name") VALUES (161, 'Niue');
INSERT INTO "Country" ("CountryId", "Name") VALUES (162, 'Norfolk Island');
INSERT INTO "Country" ("CountryId", "Name") VALUES (163, 'North Korea');
INSERT INTO "Country" ("CountryId", "Name") VALUES (164, 'North Macedonia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (165, 'Northern Mariana Islands');
INSERT INTO "Country" ("CountryId", "Name") VALUES (166, 'Norway');
INSERT INTO "Country" ("CountryId", "Name") VALUES (167, 'Oman');
INSERT INTO "Country" ("CountryId", "Name") VALUES (168, 'Pakistan');
INSERT INTO "Country" ("CountryId", "Name") VALUES (169, 'Palau');
INSERT INTO "Country" ("CountryId", "Name") VALUES (170, 'Palestinian Territories');
INSERT INTO "Country" ("CountryId", "Name") VALUES (171, 'Panama');
INSERT INTO "Country" ("CountryId", "Name") VALUES (172, 'Papua New Guinea');
INSERT INTO "Country" ("CountryId", "Name") VALUES (173, 'Paraguay');
INSERT INTO "Country" ("CountryId", "Name") VALUES (174, 'Peru');
INSERT INTO "Country" ("CountryId", "Name") VALUES (175, 'Philippines');
INSERT INTO "Country" ("CountryId", "Name") VALUES (176, 'Pitcairn Islands');
INSERT INTO "Country" ("CountryId", "Name") VALUES (177, 'Poland');
INSERT INTO "Country" ("CountryId", "Name") VALUES (178, 'Portugal');
INSERT INTO "Country" ("CountryId", "Name") VALUES (179, 'Puerto Rico');
INSERT INTO "Country" ("CountryId", "Name") VALUES (180, 'Qatar');
INSERT INTO "Country" ("CountryId", "Name") VALUES (181, 'Réunion');
INSERT INTO "Country" ("CountryId", "Name") VALUES (182, 'Romania');
INSERT INTO "Country" ("CountryId", "Name") VALUES (183, 'Russia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (184, 'Rwanda');
INSERT INTO "Country" ("CountryId", "Name") VALUES (185, 'Samoa');
INSERT INTO "Country" ("CountryId", "Name") VALUES (186, 'San Marino');
INSERT INTO "Country" ("CountryId", "Name") VALUES (187, 'São Tomé & Príncipe');
INSERT INTO "Country" ("CountryId", "Name") VALUES (188, 'Saudi Arabia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (189, 'Senegal');
INSERT INTO "Country" ("CountryId", "Name") VALUES (190, 'Serbia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (191, 'Seychelles');
INSERT INTO "Country" ("CountryId", "Name") VALUES (192, 'Sierra Leone');
INSERT INTO "Country" ("CountryId", "Name") VALUES (193, 'Singapore');
INSERT INTO "Country" ("CountryId", "Name") VALUES (194, 'Sint Maarten');
INSERT INTO "Country" ("CountryId", "Name") VALUES (195, 'Slovakia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (196, 'Slovenia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (197, 'Solomon Islands');
INSERT INTO "Country" ("CountryId", "Name") VALUES (198, 'Somalia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (199, 'South Africa');
INSERT INTO "Country" ("CountryId", "Name") VALUES (200, 'South Georgia & South Sandwich Islands');
INSERT INTO "Country" ("CountryId", "Name") VALUES (201, 'South Korea');
INSERT INTO "Country" ("CountryId", "Name") VALUES (202, 'South Sudan');
INSERT INTO "Country" ("CountryId", "Name") VALUES (203, 'Spain');
INSERT INTO "Country" ("CountryId", "Name") VALUES (204, 'Sri Lanka');
INSERT INTO "Country" ("CountryId", "Name") VALUES (205, 'St. Barthélemy');
INSERT INTO "Country" ("CountryId", "Name") VALUES (206, 'St. Helena');
INSERT INTO "Country" ("CountryId", "Name") VALUES (207, 'St. Kitts & Nevis');
INSERT INTO "Country" ("CountryId", "Name") VALUES (208, 'St. Lucia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (209, 'St. Martin');
INSERT INTO "Country" ("CountryId", "Name") VALUES (210, 'St. Pierre & Miquelon');
INSERT INTO "Country" ("CountryId", "Name") VALUES (211, 'St. Vincent & Grenadines');
INSERT INTO "Country" ("CountryId", "Name") VALUES (212, 'Sudan');
INSERT INTO "Country" ("CountryId", "Name") VALUES (213, 'Suriname');
INSERT INTO "Country" ("CountryId", "Name") VALUES (214, 'Svalbard & Jan Mayen');
INSERT INTO "Country" ("CountryId", "Name") VALUES (215, 'Sweden');
INSERT INTO "Country" ("CountryId", "Name") VALUES (216, 'Switzerland');
INSERT INTO "Country" ("CountryId", "Name") VALUES (217, 'Syria');
INSERT INTO "Country" ("CountryId", "Name") VALUES (218, 'Taiwan');
INSERT INTO "Country" ("CountryId", "Name") VALUES (219, 'Tajikistan');
INSERT INTO "Country" ("CountryId", "Name") VALUES (220, 'Tanzania');
INSERT INTO "Country" ("CountryId", "Name") VALUES (221, 'Thailand');
INSERT INTO "Country" ("CountryId", "Name") VALUES (222, 'Timor-Leste');
INSERT INTO "Country" ("CountryId", "Name") VALUES (223, 'Togo');
INSERT INTO "Country" ("CountryId", "Name") VALUES (224, 'Tokelau');
INSERT INTO "Country" ("CountryId", "Name") VALUES (225, 'Tonga');
INSERT INTO "Country" ("CountryId", "Name") VALUES (226, 'Trinidad & Tobago');
INSERT INTO "Country" ("CountryId", "Name") VALUES (227, 'Tunisia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (228, 'Turkey');
INSERT INTO "Country" ("CountryId", "Name") VALUES (229, 'Turkmenistan');
INSERT INTO "Country" ("CountryId", "Name") VALUES (230, 'Turks & Caicos Islands');
INSERT INTO "Country" ("CountryId", "Name") VALUES (231, 'Tuvalu');
INSERT INTO "Country" ("CountryId", "Name") VALUES (232, 'U.S. Outlying Islands');
INSERT INTO "Country" ("CountryId", "Name") VALUES (233, 'U.S. Virgin Islands');
INSERT INTO "Country" ("CountryId", "Name") VALUES (234, 'Uganda');
INSERT INTO "Country" ("CountryId", "Name") VALUES (235, 'Ukraine');
INSERT INTO "Country" ("CountryId", "Name") VALUES (236, 'United Arab Emirates');
INSERT INTO "Country" ("CountryId", "Name") VALUES (237, 'United Kingdom');
INSERT INTO "Country" ("CountryId", "Name") VALUES (238, 'United States');
INSERT INTO "Country" ("CountryId", "Name") VALUES (239, 'Uruguay');
INSERT INTO "Country" ("CountryId", "Name") VALUES (240, 'Uzbekistan');
INSERT INTO "Country" ("CountryId", "Name") VALUES (241, 'Vanuatu');
INSERT INTO "Country" ("CountryId", "Name") VALUES (242, 'Vatican City');
INSERT INTO "Country" ("CountryId", "Name") VALUES (243, 'Venezuela');
INSERT INTO "Country" ("CountryId", "Name") VALUES (244, 'Vietnam');
INSERT INTO "Country" ("CountryId", "Name") VALUES (245, 'Wallis & Futuna');
INSERT INTO "Country" ("CountryId", "Name") VALUES (246, 'Western Sahara');
INSERT INTO "Country" ("CountryId", "Name") VALUES (247, 'Yemen');
INSERT INTO "Country" ("CountryId", "Name") VALUES (248, 'Zambia');
INSERT INTO "Country" ("CountryId", "Name") VALUES (249, 'Zimbabwe');

INSERT INTO "Tag" ("TagId", "Name") VALUES (13, 'Problem Solving');
INSERT INTO "Tag" ("TagId", "Name") VALUES (14, 'Tricks');
INSERT INTO "Tag" ("TagId", "Name") VALUES (15, 'Array Rotation');
INSERT INTO "Tag" ("TagId", "Name") VALUES (16, 'Bit Manipulation');
INSERT INTO "Tag" ("TagId", "Name") VALUES (17, 'Common thinking process');
INSERT INTO "Tag" ("TagId", "Name") VALUES (18, 'State graph');
INSERT INTO "Tag" ("TagId", "Name") VALUES (19, 'Recursion');
INSERT INTO "Tag" ("TagId", "Name") VALUES (20, 'Prefixes and suffixes');
INSERT INTO "Tag" ("TagId", "Name") VALUES (21, 'Sweep line');
INSERT INTO "Tag" ("TagId", "Name") VALUES (22, 'Considering parity');
INSERT INTO "Tag" ("TagId", "Name") VALUES (23, 'Restrict the answer');
INSERT INTO "Tag" ("TagId", "Name") VALUES (24, 'Simplification');
INSERT INTO "Tag" ("TagId", "Name") VALUES (25, 'Problem statement simplification');
INSERT INTO "Tag" ("TagId", "Name") VALUES (26, 'Dimension simplification');
INSERT INTO "Tag" ("TagId", "Name") VALUES (27, 'Sorting simplification');
INSERT INTO "Tag" ("TagId", "Name") VALUES (28, 'Compression');
INSERT INTO "Tag" ("TagId", "Name") VALUES (29, 'Queries');
INSERT INTO "Tag" ("TagId", "Name") VALUES (30, 'Storing results');
INSERT INTO "Tag" ("TagId", "Name") VALUES (31, 'Interactive');
INSERT INTO "Tag" ("TagId", "Name") VALUES (32, 'Mapping');
INSERT INTO "Tag" ("TagId", "Name") VALUES (33, 'Testing');
INSERT INTO "Tag" ("TagId", "Name") VALUES (34, 'Brute force');
INSERT INTO "Tag" ("TagId", "Name") VALUES (35, 'Loop design');
INSERT INTO "Tag" ("TagId", "Name") VALUES (36, 'Linear search');
INSERT INTO "Tag" ("TagId", "Name") VALUES (37, 'Backtracking');
INSERT INTO "Tag" ("TagId", "Name") VALUES (38, 'Branch and bound');
INSERT INTO "Tag" ("TagId", "Name") VALUES (39, 'Simulation');
INSERT INTO "Tag" ("TagId", "Name") VALUES (40, 'Mo');
INSERT INTO "Tag" ("TagId", "Name") VALUES (41, 'Meet in the middle');
INSERT INTO "Tag" ("TagId", "Name") VALUES (42, 'Greedy');
INSERT INTO "Tag" ("TagId", "Name") VALUES (43, 'Two pointers');
INSERT INTO "Tag" ("TagId", "Name") VALUES (44, 'Sliding window');
INSERT INTO "Tag" ("TagId", "Name") VALUES (45, 'Binary search');
INSERT INTO "Tag" ("TagId", "Name") VALUES (46, 'Ternary search');
INSERT INTO "Tag" ("TagId", "Name") VALUES (47, 'Sortings');
INSERT INTO "Tag" ("TagId", "Name") VALUES (48, 'Kruskal');
INSERT INTO "Tag" ("TagId", "Name") VALUES (49, 'Prim');
INSERT INTO "Tag" ("TagId", "Name") VALUES (50, 'Graph');
INSERT INTO "Tag" ("TagId", "Name") VALUES (51, 'Traversing');
INSERT INTO "Tag" ("TagId", "Name") VALUES (52, 'DFS');
INSERT INTO "Tag" ("TagId", "Name") VALUES (53, 'BFS');
INSERT INTO "Tag" ("TagId", "Name") VALUES (54, 'Connectivity');
INSERT INTO "Tag" ("TagId", "Name") VALUES (55, 'Connected components');
INSERT INTO "Tag" ("TagId", "Name") VALUES (56, 'DFS tree');
INSERT INTO "Tag" ("TagId", "Name") VALUES (57, 'Bridges');
INSERT INTO "Tag" ("TagId", "Name") VALUES (58, 'Articulation points');
INSERT INTO "Tag" ("TagId", "Name") VALUES (59, 'Strongly connected components');
INSERT INTO "Tag" ("TagId", "Name") VALUES (60, 'Shortest paths');
INSERT INTO "Tag" ("TagId", "Name") VALUES (61, 'Dijkstra');
INSERT INTO "Tag" ("TagId", "Name") VALUES (62, 'Bellman-Ford');
INSERT INTO "Tag" ("TagId", "Name") VALUES (63, 'Floyd-Warshall');
INSERT INTO "Tag" ("TagId", "Name") VALUES (64, '0/1 BFS');
INSERT INTO "Tag" ("TagId", "Name") VALUES (65, 'Flows and cuts');
INSERT INTO "Tag" ("TagId", "Name") VALUES (66, 'Ford-Fulkerson');
INSERT INTO "Tag" ("TagId", "Name") VALUES (67, 'Edmods-Karp');
INSERT INTO "Tag" ("TagId", "Name") VALUES (68, 'Push-relabel');
INSERT INTO "Tag" ("TagId", "Name") VALUES (69, 'Dinic');
INSERT INTO "Tag" ("TagId", "Name") VALUES (70, 'MPM');
INSERT INTO "Tag" ("TagId", "Name") VALUES (71, 'Minimum spanning trees');
INSERT INTO "Tag" ("TagId", "Name") VALUES (72, 'Cycles');
INSERT INTO "Tag" ("TagId", "Name") VALUES (73, 'Simple cycles');
INSERT INTO "Tag" ("TagId", "Name") VALUES (74, 'Negative cycles');
INSERT INTO "Tag" ("TagId", "Name") VALUES (75, 'Euler path/cycle');
INSERT INTO "Tag" ("TagId", "Name") VALUES (76, 'Hamiltonian path/cycle');
INSERT INTO "Tag" ("TagId", "Name") VALUES (77, 'Tree');
INSERT INTO "Tag" ("TagId", "Name") VALUES (78, 'Lowest common ancestor');
INSERT INTO "Tag" ("TagId", "Name") VALUES (79, 'Centroid decomposition');
INSERT INTO "Tag" ("TagId", "Name") VALUES (80, 'Heavy-light decomposition');
INSERT INTO "Tag" ("TagId", "Name") VALUES (81, 'Centroid');
INSERT INTO "Tag" ("TagId", "Name") VALUES (82, 'Center');
INSERT INTO "Tag" ("TagId", "Name") VALUES (83, 'Diameter');
INSERT INTO "Tag" ("TagId", "Name") VALUES (84, 'Binary tree');
INSERT INTO "Tag" ("TagId", "Name") VALUES (85, 'Topological sort');
INSERT INTO "Tag" ("TagId", "Name") VALUES (86, '2SAT');
INSERT INTO "Tag" ("TagId", "Name") VALUES (87, 'Bipartite graph');
INSERT INTO "Tag" ("TagId", "Name") VALUES (88, 'Turbo matching');
INSERT INTO "Tag" ("TagId", "Name") VALUES (89, 'String');
INSERT INTO "Tag" ("TagId", "Name") VALUES (90, 'Pattern matching');
INSERT INTO "Tag" ("TagId", "Name") VALUES (91, 'Hashing');
INSERT INTO "Tag" ("TagId", "Name") VALUES (92, 'Rabin-Karp');
INSERT INTO "Tag" ("TagId", "Name") VALUES (93, 'KMP');
INSERT INTO "Tag" ("TagId", "Name") VALUES (94, 'Suffix array');
INSERT INTO "Tag" ("TagId", "Name") VALUES (95, 'Trie');
INSERT INTO "Tag" ("TagId", "Name") VALUES (96, 'Palindrome');
INSERT INTO "Tag" ("TagId", "Name") VALUES (97, 'Palindrome tree');
INSERT INTO "Tag" ("TagId", "Name") VALUES (98, 'Manacher');
INSERT INTO "Tag" ("TagId", "Name") VALUES (99, 'Math');
INSERT INTO "Tag" ("TagId", "Name") VALUES (100, 'Geometry');
INSERT INTO "Tag" ("TagId", "Name") VALUES (101, 'Points and vectors');
INSERT INTO "Tag" ("TagId", "Name") VALUES (102, 'Precision issues');
INSERT INTO "Tag" ("TagId", "Name") VALUES (103, 'Transformations');
INSERT INTO "Tag" ("TagId", "Name") VALUES (104, 'Products and angles');
INSERT INTO "Tag" ("TagId", "Name") VALUES (105, 'Lines');
INSERT INTO "Tag" ("TagId", "Name") VALUES (106, 'Segments');
INSERT INTO "Tag" ("TagId", "Name") VALUES (107, 'Circles');
INSERT INTO "Tag" ("TagId", "Name") VALUES (108, '3D geometry');
INSERT INTO "Tag" ("TagId", "Name") VALUES (109, 'Planes');
INSERT INTO "Tag" ("TagId", "Name") VALUES (110, 'Angular sort');
INSERT INTO "Tag" ("TagId", "Name") VALUES (111, 'Convex hull');
INSERT INTO "Tag" ("TagId", "Name") VALUES (112, 'Polygon area');
INSERT INTO "Tag" ("TagId", "Name") VALUES (113, 'Number theory');
INSERT INTO "Tag" ("TagId", "Name") VALUES (114, 'Primality testing');
INSERT INTO "Tag" ("TagId", "Name") VALUES (115, 'Factorization');
INSERT INTO "Tag" ("TagId", "Name") VALUES (116, 'Euclidean algorithm');
INSERT INTO "Tag" ("TagId", "Name") VALUES (117, 'Sieve of Eratosthenes');
INSERT INTO "Tag" ("TagId", "Name") VALUES (118, 'Game theory');
INSERT INTO "Tag" ("TagId", "Name") VALUES (119, 'Sprague-Grundy theorem');
INSERT INTO "Tag" ("TagId", "Name") VALUES (120, 'Nim game');
INSERT INTO "Tag" ("TagId", "Name") VALUES (121, 'Arbitrary precision arithmetic');
INSERT INTO "Tag" ("TagId", "Name") VALUES (122, 'Pigeon hole');
INSERT INTO "Tag" ("TagId", "Name") VALUES (123, 'Inclusion-exclusion');
INSERT INTO "Tag" ("TagId", "Name") VALUES (124, 'Binary exponentation');
INSERT INTO "Tag" ("TagId", "Name") VALUES (125, 'Matrix');
INSERT INTO "Tag" ("TagId", "Name") VALUES (126, 'Real numbers');
INSERT INTO "Tag" ("TagId", "Name") VALUES (127, 'FFT');
INSERT INTO "Tag" ("TagId", "Name") VALUES (128, 'Dynamic programming');
INSERT INTO "Tag" ("TagId", "Name") VALUES (129, 'Classical DP problems');
INSERT INTO "Tag" ("TagId", "Name") VALUES (130, 'Maximum subarray sum');
INSERT INTO "Tag" ("TagId", "Name") VALUES (131, 'Longest increasing subsequence');
INSERT INTO "Tag" ("TagId", "Name") VALUES (132, 'Longest common subsequence');
INSERT INTO "Tag" ("TagId", "Name") VALUES (133, 'Edit distance');
INSERT INTO "Tag" ("TagId", "Name") VALUES (134, 'Coin change');
INSERT INTO "Tag" ("TagId", "Name") VALUES (135, 'Knapsack');
INSERT INTO "Tag" ("TagId", "Name") VALUES (136, 'Egg dropping');
INSERT INTO "Tag" ("TagId", "Name") VALUES (137, 'DP optimization');
INSERT INTO "Tag" ("TagId", "Name") VALUES (138, 'Knuth optimization');
INSERT INTO "Tag" ("TagId", "Name") VALUES (139, 'Divide and conquer optimization');
INSERT INTO "Tag" ("TagId", "Name") VALUES (140, 'Convex hull optimization');
INSERT INTO "Tag" ("TagId", "Name") VALUES (141, 'Segment tree');
INSERT INTO "Tag" ("TagId", "Name") VALUES (142, 'Prefix and suffix structures');
INSERT INTO "Tag" ("TagId", "Name") VALUES (143, 'Monotonic queue');
INSERT INTO "Tag" ("TagId", "Name") VALUES (144, 'Tree DP');
INSERT INTO "Tag" ("TagId", "Name") VALUES (145, 'Bitmask DP');
INSERT INTO "Tag" ("TagId", "Name") VALUES (146, 'Prefix DP');
INSERT INTO "Tag" ("TagId", "Name") VALUES (147, 'Range DP');
INSERT INTO "Tag" ("TagId", "Name") VALUES (148, 'Data structures');
INSERT INTO "Tag" ("TagId", "Name") VALUES (149, 'STL');
INSERT INTO "Tag" ("TagId", "Name") VALUES (150, 'Array');
INSERT INTO "Tag" ("TagId", "Name") VALUES (151, 'Vector');
INSERT INTO "Tag" ("TagId", "Name") VALUES (152, 'Stack');
INSERT INTO "Tag" ("TagId", "Name") VALUES (153, 'Queue');
INSERT INTO "Tag" ("TagId", "Name") VALUES (154, 'Deque');
INSERT INTO "Tag" ("TagId", "Name") VALUES (155, 'Priority queue');
INSERT INTO "Tag" ("TagId", "Name") VALUES (156, 'Set');
INSERT INTO "Tag" ("TagId", "Name") VALUES (157, 'Map');
INSERT INTO "Tag" ("TagId", "Name") VALUES (158, 'List');
INSERT INTO "Tag" ("TagId", "Name") VALUES (159, 'Ordered set');
INSERT INTO "Tag" ("TagId", "Name") VALUES (160, 'Range queries data structures');
INSERT INTO "Tag" ("TagId", "Name") VALUES (161, 'Fenwick tree');
INSERT INTO "Tag" ("TagId", "Name") VALUES (162, 'Sparse table');
INSERT INTO "Tag" ("TagId", "Name") VALUES (163, 'Sqrt structures');
INSERT INTO "Tag" ("TagId", "Name") VALUES (164, 'Monotonic structures');
INSERT INTO "Tag" ("TagId", "Name") VALUES (165, 'Monotonic stack');
INSERT INTO "Tag" ("TagId", "Name") VALUES (166, 'Min/max stack');
INSERT INTO "Tag" ("TagId", "Name") VALUES (167, 'Disjoint set union');
INSERT INTO "Tag" ("TagId", "Name") VALUES (168, 'Binary search tree');

INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (13, 14);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (13, 15);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (14, 15);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (13, 16);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (14, 16);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (13, 17);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (13, 18);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (17, 18);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (13, 19);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (17, 19);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (13, 20);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (17, 20);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (13, 21);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (17, 21);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (13, 22);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (17, 22);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (13, 23);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (17, 23);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (13, 24);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (13, 25);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (24, 25);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (13, 26);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (24, 26);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (13, 27);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (24, 27);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (13, 28);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (24, 28);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (13, 29);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (13, 30);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (29, 30);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (13, 31);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (13, 32);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (13, 33);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (34, 35);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (34, 36);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (34, 37);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (34, 38);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (34, 39);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (34, 40);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (34, 41);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (42, 43);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (42, 44);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (42, 45);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (42, 46);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (42, 47);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (42, 48);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (42, 49);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 51);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 52);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (51, 52);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 53);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (51, 53);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 54);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 55);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (54, 55);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 56);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (54, 56);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 57);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (54, 57);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (56, 57);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 58);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (54, 58);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (56, 58);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 59);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (54, 59);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 60);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 61);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (60, 61);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 62);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (60, 62);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 63);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (60, 63);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (60, 53);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 64);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (60, 64);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 65);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 66);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (65, 66);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 67);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (65, 67);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 68);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (65, 68);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 69);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (65, 69);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 70);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (65, 70);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 71);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 49);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (71, 49);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 48);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (71, 48);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 72);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 73);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (72, 73);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 74);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (72, 74);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 75);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (72, 75);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 76);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (72, 76);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 77);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 78);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (77, 78);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 79);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (77, 79);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 80);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (77, 80);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 81);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (77, 81);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 82);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (77, 82);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 83);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (77, 83);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 84);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (77, 84);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 85);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 86);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 87);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (50, 88);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (89, 90);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (89, 91);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (90, 91);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (89, 92);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (90, 92);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (89, 93);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (90, 93);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (89, 94);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (90, 94);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (89, 95);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (90, 95);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (89, 96);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (89, 97);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (96, 97);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (89, 98);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (96, 98);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 100);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 101);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (100, 101);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 102);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (100, 102);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 103);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (100, 103);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 104);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (100, 104);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 105);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (100, 105);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 106);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (100, 106);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 107);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (100, 107);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 108);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (100, 108);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 109);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (100, 109);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 110);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (100, 110);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 111);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (100, 111);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 112);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (100, 112);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 113);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 114);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (113, 114);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 115);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (113, 115);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 116);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (113, 116);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 117);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (113, 117);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 118);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 119);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (118, 119);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 120);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (118, 120);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 121);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 122);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 123);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 124);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 125);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 126);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (99, 127);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (128, 129);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (128, 130);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (129, 130);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (128, 131);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (129, 131);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (128, 132);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (129, 132);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (128, 133);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (129, 133);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (128, 134);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (129, 134);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (128, 135);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (129, 135);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (128, 136);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (129, 136);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (128, 137);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (128, 138);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (137, 138);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (128, 139);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (137, 139);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (128, 140);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (137, 140);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (128, 141);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (137, 141);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (128, 142);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (137, 142);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (128, 143);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (137, 143);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (128, 144);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (128, 145);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (128, 146);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (128, 147);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 149);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 150);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (149, 150);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 151);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (149, 151);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 89);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (149, 89);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 152);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (149, 152);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 153);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (149, 153);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 154);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (149, 154);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 155);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (149, 155);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 156);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (149, 156);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 157);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (149, 157);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 158);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (149, 158);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 159);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (149, 159);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 160);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 161);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (160, 161);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 141);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (160, 141);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 162);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (160, 162);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 163);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (160, 163);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 142);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (160, 142);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 164);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 143);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (164, 143);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 165);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (164, 165);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 166);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (164, 166);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 50);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 77);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 167);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 94);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 168);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 97);
INSERT INTO "TagCategory" ("ParentTagId", "TagId") VALUES (148, 95);

INSERT INTO "Source" ("SourceId", "Name") VALUES (1, 'Defense Complex');
INSERT INTO "Source" ("SourceId", "Name") VALUES (2, 'Jakritin 40 (Number 30)');
INSERT INTO "Source" ("SourceId", "Name") VALUES (3, 'Terbinafine Hydrochloride');
INSERT INTO "Source" ("SourceId", "Name") VALUES (4, 'VFEND');
INSERT INTO "Source" ("SourceId", "Name") VALUES (5, 'Diovan');
INSERT INTO "Source" ("SourceId", "Name") VALUES (6, 'Spring (Water) Birch');
INSERT INTO "Source" ("SourceId", "Name") VALUES (7, 'Methocarbamol');
INSERT INTO "Source" ("SourceId", "Name") VALUES (8, 'FACE IT OIL CUT DUAL BB EMULSION SPF20');
INSERT INTO "Source" ("SourceId", "Name") VALUES (9, 'AGRAPHIS NUTANS');
INSERT INTO "Source" ("SourceId", "Name") VALUES (10, 'Yellow Jacket hymenoptera venom Venomil Diagnostic');
INSERT INTO "Source" ("SourceId", "Name") VALUES (11, 'Drosera Homaccord');
INSERT INTO "Source" ("SourceId", "Name") VALUES (12, 'Eye Itch');
INSERT INTO "Source" ("SourceId", "Name") VALUES (13, 'ibuprofen');
INSERT INTO "Source" ("SourceId", "Name") VALUES (14, 'CVS Deep Cleansing Astringent');
INSERT INTO "Source" ("SourceId", "Name") VALUES (15, 'Good Neighbor Pharmacy Stay Awake');
INSERT INTO "Source" ("SourceId", "Name") VALUES (16, 'LBEL COULEUR LUXE AMPLIFIER XP');
INSERT INTO "Source" ("SourceId", "Name") VALUES (17, 'CVS');
INSERT INTO "Source" ("SourceId", "Name") VALUES (18, 'ELIDEL');
INSERT INTO "Source" ("SourceId", "Name") VALUES (19, 'SPF-30 BB');
INSERT INTO "Source" ("SourceId", "Name") VALUES (20, 'Banana Boat Sport Performance');
INSERT INTO "Source" ("SourceId", "Name") VALUES (21, 'COLD SORE SUPPORT');
INSERT INTO "Source" ("SourceId", "Name") VALUES (22, 'Pamidronate Disodium');
INSERT INTO "Source" ("SourceId", "Name") VALUES (23, 'Mellow Out');
INSERT INTO "Source" ("SourceId", "Name") VALUES (24, 'Desoximetasone');
INSERT INTO "Source" ("SourceId", "Name") VALUES (25, 'Blemish Control Blotting Paper');
INSERT INTO "Source" ("SourceId", "Name") VALUES (26, 'Roll On Anti Perspirant');
INSERT INTO "Source" ("SourceId", "Name") VALUES (27, 'Dapsone');
INSERT INTO "Source" ("SourceId", "Name") VALUES (28, 'Panache');
INSERT INTO "Source" ("SourceId", "Name") VALUES (29, 'Promethazine Hydrochloride');
INSERT INTO "Source" ("SourceId", "Name") VALUES (30, 'Lovastatin');
INSERT INTO "Source" ("SourceId", "Name") VALUES (31, 'HAWAIIAN Tropic');
INSERT INTO "Source" ("SourceId", "Name") VALUES (32, 'Hydrocortisone');
INSERT INTO "Source" ("SourceId", "Name") VALUES (33, 'Personal Care Petroleum Jelly Skin Protectant');
INSERT INTO "Source" ("SourceId", "Name") VALUES (34, 'Lamotrigine Extended Release');
INSERT INTO "Source" ("SourceId", "Name") VALUES (35, 'Clonidine Hydrochloride');
INSERT INTO "Source" ("SourceId", "Name") VALUES (36, 'Fluvoxamine Maleate');
INSERT INTO "Source" ("SourceId", "Name") VALUES (37, 'Low Dose Aspirin');
INSERT INTO "Source" ("SourceId", "Name") VALUES (38, '7 Select Aspirin');
INSERT INTO "Source" ("SourceId", "Name") VALUES (39, 'Trimethobenzamide Hydrochloride');
INSERT INTO "Source" ("SourceId", "Name") VALUES (40, 'PARURE DE LUMIERE LIGHT-DIFFUSING FOUNDATION WITH SUNSCREEN MOISTURE INFUSION BROAD SPECTRUM SPF 25 01 BEIGE PALE');
INSERT INTO "Source" ("SourceId", "Name") VALUES (41, 'Aspergillus flavus');
INSERT INTO "Source" ("SourceId", "Name") VALUES (42, 'REVITEALIZE');
INSERT INTO "Source" ("SourceId", "Name") VALUES (43, 'Pollens - Trees, Cypress, Bald Taxodium distichum');
INSERT INTO "Source" ("SourceId", "Name") VALUES (44, 'Gabapentin');
INSERT INTO "Source" ("SourceId", "Name") VALUES (45, 'SHISEIDO ULTIMATE SUN PROTECTION');
INSERT INTO "Source" ("SourceId", "Name") VALUES (46, 'Treatment Set TS351200');
INSERT INTO "Source" ("SourceId", "Name") VALUES (47, 'Tikosyn');
INSERT INTO "Source" ("SourceId", "Name") VALUES (48, 'PATANASE');
INSERT INTO "Source" ("SourceId", "Name") VALUES (49, 'Azasan');
INSERT INTO "Source" ("SourceId", "Name") VALUES (50, 'Pleo Rec');
INSERT INTO "Source" ("SourceId", "Name") VALUES (51, 'mapap arthritis pain');
INSERT INTO "Source" ("SourceId", "Name") VALUES (52, 'Hydroxyzine Pamoate');
INSERT INTO "Source" ("SourceId", "Name") VALUES (53, 'Homeopathic Facial Redness Formula');
INSERT INTO "Source" ("SourceId", "Name") VALUES (54, 'Weight Loss');
INSERT INTO "Source" ("SourceId", "Name") VALUES (55, 'Haloperidol');
INSERT INTO "Source" ("SourceId", "Name") VALUES (56, 'ESSENCE OF BEAUTY');
INSERT INTO "Source" ("SourceId", "Name") VALUES (57, 'OXYGEN');
INSERT INTO "Source" ("SourceId", "Name") VALUES (58, 'Haloperidol');
INSERT INTO "Source" ("SourceId", "Name") VALUES (59, 'By Nature Daily Face Sunscreen');
INSERT INTO "Source" ("SourceId", "Name") VALUES (60, 'Metformin hydrochloride');
INSERT INTO "Source" ("SourceId", "Name") VALUES (61, 'Terrasil Molluscum Treatment');
INSERT INTO "Source" ("SourceId", "Name") VALUES (62, 'good sense all day pain relief');
INSERT INTO "Source" ("SourceId", "Name") VALUES (63, 'OMNI');
INSERT INTO "Source" ("SourceId", "Name") VALUES (64, 'Olanzapine');
INSERT INTO "Source" ("SourceId", "Name") VALUES (65, 'Zovia 1/35E-28');
INSERT INTO "Source" ("SourceId", "Name") VALUES (66, 'biokera');
INSERT INTO "Source" ("SourceId", "Name") VALUES (67, 'Rite Aid Instant Hand Sanitizer With Moisturizers');
INSERT INTO "Source" ("SourceId", "Name") VALUES (68, 'IPKN MOIST AND FIRM BB 01 FAIR');
INSERT INTO "Source" ("SourceId", "Name") VALUES (69, 'Atenolol');
INSERT INTO "Source" ("SourceId", "Name") VALUES (70, 'Losartan Potassium');
INSERT INTO "Source" ("SourceId", "Name") VALUES (71, 'Trazodone Hydrochloride');
INSERT INTO "Source" ("SourceId", "Name") VALUES (72, 'Breast Cyst and Discomforts');
INSERT INTO "Source" ("SourceId", "Name") VALUES (73, 'Codfish');
INSERT INTO "Source" ("SourceId", "Name") VALUES (74, 'Oxycodone Hydchloride');
INSERT INTO "Source" ("SourceId", "Name") VALUES (75, 'Carbon Dioxide Oxygen Mix');
INSERT INTO "Source" ("SourceId", "Name") VALUES (76, 'Methylphenidate Hydrochloride');
INSERT INTO "Source" ("SourceId", "Name") VALUES (77, 'Tarceva');
INSERT INTO "Source" ("SourceId", "Name") VALUES (78, 'Estradiol Transdermal System');
INSERT INTO "Source" ("SourceId", "Name") VALUES (79, 'venlafaxine hydrochloride');
INSERT INTO "Source" ("SourceId", "Name") VALUES (80, 'First Aid');
INSERT INTO "Source" ("SourceId", "Name") VALUES (81, 'Ranexa');
INSERT INTO "Source" ("SourceId", "Name") VALUES (82, 'SEROQUEL');
INSERT INTO "Source" ("SourceId", "Name") VALUES (83, 'PANADOL');
INSERT INTO "Source" ("SourceId", "Name") VALUES (84, 'Lornamead');
INSERT INTO "Source" ("SourceId", "Name") VALUES (85, 'Quetiapine fumarate');
INSERT INTO "Source" ("SourceId", "Name") VALUES (86, 'nicotine polacrilex');
INSERT INTO "Source" ("SourceId", "Name") VALUES (87, 'CORGARD');
INSERT INTO "Source" ("SourceId", "Name") VALUES (88, 'ESIKA HD COLOR HIGH DEFINITION COLOR SPF 20');
INSERT INTO "Source" ("SourceId", "Name") VALUES (89, 'Desmopressin Acetate');
INSERT INTO "Source" ("SourceId", "Name") VALUES (90, 'Molds, Rusts and Smuts, Penicillium notatum');
INSERT INTO "Source" ("SourceId", "Name") VALUES (91, 'Imipramine Hydrochloride');
INSERT INTO "Source" ("SourceId", "Name") VALUES (92, 'Antacid');
INSERT INTO "Source" ("SourceId", "Name") VALUES (93, 'TopCare Complete');
INSERT INTO "Source" ("SourceId", "Name") VALUES (94, 'Allergy Relief');
INSERT INTO "Source" ("SourceId", "Name") VALUES (95, 'Keppra');
INSERT INTO "Source" ("SourceId", "Name") VALUES (96, 'Anti-Diarrheal');
INSERT INTO "Source" ("SourceId", "Name") VALUES (97, 'Digoxin');
INSERT INTO "Source" ("SourceId", "Name") VALUES (98, 'nicotine');
INSERT INTO "Source" ("SourceId", "Name") VALUES (99, 'Temazepam');
INSERT INTO "Source" ("SourceId", "Name") VALUES (100, 'BION TEARS');

INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (1, 48, 7, 3, false, 'Pollens - Weeds and Garden Plants, Nettle Urtica dioica', 1);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (2, 6, 7, 2, false, 'ESIKA', 2);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (3, 69, 9, 4, true, 'Purminerals 4-in-1 14-Hour Wear Foundation Broad Spectrum SPF 15 (TAN)', 3);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (4, 2, 9, 4, false, 'Antibacterial Hand Arctic blast', 4);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (5, 3, 1, 5, true, 'Yellow Dock', 5);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (6, 43, 9, 1, true, 'Tranxene', 6);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (7, 67, 4, 3, true, 'Lyrica', 7);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (8, 67, 8, 1, true, 'OXYCODONE AND ACETAMINOPHEN', 8);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (9, 16, 6, 2, false, 'Gabapentin', 9);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (10, 30, 7, 3, true, 'Amoxicillin', 10);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (11, 58, 8, 2, false, 'Olanzapine and Fluoxetine', 11);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (12, 14, 4, 2, true, 'Carvedilol', 12);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (13, 58, 2, 3, true, 'Topotecan', 13);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (14, 48, 7, 5, true, 'Pain Relief PM', 14);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (15, 46, 3, 1, false, 'Lexapro', 15);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (16, 11, 4, 4, false, 'SAVELLA', 16);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (17, 57, 9, 4, false, 'Lisinopril', 17);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (18, 64, 10, 4, true, 'Loxapine', 18);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (19, 23, 6, 3, false, 'Pleo Ut S', 19);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (20, 56, 5, 1, false, 'Hydrocodone Bitartrate and Homatropine Methylbromide', 20);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (21, 20, 7, 3, true, 'Cefuroxime Axetil', 21);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (22, 17, 7, 5, true, 'Equaline ibuprofen', 22);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (23, 22, 1, 3, false, 'Long-Lasting Oil-Free Moisturizer', 23);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (24, 29, 4, 4, true, 'DOCUSATE SODIUM', 24);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (25, 9, 7, 1, false, 'Parsnip', 25);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (26, 42, 1, 1, true, 'Remedy Barrier Cream Cloths', 26);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (27, 55, 2, 4, false, 'Estradiol', 27);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (28, 32, 7, 2, false, 'Goldenrod', 28);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (29, 43, 10, 3, false, 'Natural Fiber Powder', 29);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (30, 29, 9, 4, false, 'Fleet', 30);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (31, 75, 8, 3, true, 'Pentoxifylline', 31);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (32, 11, 1, 3, false, 'Etodolac', 32);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (33, 56, 8, 1, false, 'Conazol', 33);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (34, 6, 8, 1, false, 'Losartan Potassium', 34);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (35, 21, 7, 5, false, 'HYDROCODONE BITARTRATE AND ACETAMINOPHEN', 35);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (36, 54, 4, 4, true, 'Lamotrigine', 36);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (37, 72, 3, 4, true, 'Perfect Purity HotIce', 37);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (38, 62, 6, 3, false, 'Simvastatin', 38);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (39, 37, 8, 3, true, 'BencoCaine Topical Anesthetic', 39);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (40, 55, 1, 4, true, 'Quetiapine fumarate', 40);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (41, 35, 2, 5, false, 'Major Redness Reliever Eye', 41);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (42, 19, 7, 4, true, 'rx act antacid', 42);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (43, 2, 9, 4, false, 'Leg Strong Trifusion', 43);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (44, 63, 10, 5, true, 'care one calcium antacid', 44);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (45, 8, 7, 4, false, 'Metoprolol Succinate', 45);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (46, 25, 6, 2, true, 'ARTISTRY Time Defiance UV Defense SPF 50 Ultra Facial Sunscreen', 46);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (47, 54, 5, 5, true, 'Topiramate', 47);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (48, 49, 4, 2, false, 'Etidronate Disodium', 48);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (49, 4, 3, 3, true, 'miconazole 1', 49);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (50, 27, 3, 3, false, 'Lyrica', 50);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (51, 70, 4, 5, false, 'DOCUSATE SODIUM', 51);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (52, 67, 5, 2, true, 'CAPTURE TOTALE COMPACT RADIANCE RESTORING LINE SMOOTHING MAKEUP SPF 20 020 Light Beige', 52);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (53, 72, 4, 4, true, 'Servo-Stat T', 53);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (54, 63, 3, 4, true, 'BIRDS GARDEN LIP BALM', 54);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (55, 65, 9, 2, false, 'Quick n Clean Antiseptic Hand Wipe', 55);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (56, 13, 2, 2, true, '60-Second Fluoride', 56);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (57, 10, 1, 2, false, 'Oxcarbazepine', 57);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (58, 27, 7, 2, true, 'Anti Hive', 58);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (59, 64, 3, 4, true, 'Topiclear Carrot', 59);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (60, 9, 5, 2, true, 'Indigestion', 60);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (61, 56, 1, 3, true, 'Clonazepam', 61);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (62, 3, 8, 2, true, 'Quinapril Hydrochloride/Hydrochlorothiazide', 62);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (63, 13, 10, 1, false, 'Standardized Grass Pollen, Sweet Vernal Grass', 63);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (64, 25, 2, 4, true, 'Para Grass Pollen', 64);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (65, 27, 2, 3, false, 'SODIUM SULFACETAMIDE and SULFUR', 65);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (66, 31, 1, 5, false, 'Desenex', 66);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (67, 18, 6, 4, false, 'OXYMETAZOLINE HYDROCHLORIDE', 67);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (68, 49, 8, 1, false, 'Asacol', 68);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (69, 55, 1, 4, true, 'Benazepril Hydrochloride and Hydrochlorothiazide', 69);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (70, 20, 9, 2, false, 'Amoxicillin and Clavulanate Potassium', 70);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (71, 66, 9, 4, false, 'ATORVASTATIN CALCIUM', 71);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (72, 75, 6, 3, true, 'Levalbuterol Hydrochloride', 72);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (73, 57, 6, 1, false, 'O HUI WRINKLE SCIENCE WRINKLE REPAIR', 73);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (74, 57, 5, 4, false, 'junior strength acetaminophen', 74);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (75, 12, 10, 5, true, 'Ascriptin', 75);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (76, 30, 7, 4, true, 'Mistletoe and Mint Antibacterial Foaming Hand Wash', 76);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (77, 72, 2, 2, false, 'Cultivated Rye', 77);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (78, 40, 10, 3, false, 'ANTI ITCH', 78);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (79, 21, 3, 1, false, 'Yves Saint Laurent', 79);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (80, 73, 9, 5, true, 'Cefdinir', 80);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (81, 15, 3, 1, true, 'SODIUM SULFACETAMIDE', 81);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (82, 31, 6, 3, true, 'Butalbital, Acetaminophen and Caffeine', 82);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (83, 18, 8, 5, false, 'Indomethacin', 83);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (84, 55, 10, 1, false, 'Mirapharm-22', 84);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (85, 2, 5, 5, false, 'Dr.eslee Intensive Recovery Blemish Balm', 85);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (86, 19, 8, 3, true, 'Proactiv Renewing Cleanser', 86);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (87, 67, 6, 1, false, 'CLONIDINE HYDROCHLORIDE', 87);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (88, 31, 6, 1, true, 'DesOwen', 88);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (89, 27, 1, 2, true, 'bicalutamide', 89);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (90, 28, 10, 2, false, 'Griseofulvin', 90);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (91, 69, 8, 4, true, 'kids cough', 91);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (92, 30, 10, 2, true, 'Slash Pine', 92);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (93, 62, 6, 4, false, 'simply right famotidine complete', 93);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (94, 22, 7, 5, true, 'Minivelle', 94);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (95, 34, 10, 1, false, 'Dicloxacillin Sodium', 95);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (96, 57, 9, 3, false, 'HAND SANITIZER', 96);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (97, 57, 9, 4, false, 'Head and Shoulders', 97);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (98, 14, 10, 5, true, 'White Birch', 98);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (99, 21, 2, 4, true, 'medroxyprogesterone acetate', 99);
INSERT INTO "Problem" ("ProblemId", "SourceId", "Difficulty","Quality", "IsPublic", "Name", "Path") VALUES (100, 16, 1, 3, true, 'Felbamate', 100);

INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(91, 37, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(75, 48, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(36, 100, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(61, 24, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(56, 76, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(72, 21, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(42, 66, 8);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(62, 47, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(59, 91, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(23, 62, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(46, 52, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(46, 29, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(42, 77, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(24, 93, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(8, 95, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(81, 16, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(39, 95, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(76, 75, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(22, 73, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(58, 84, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(25, 60, 8);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(36, 17, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(93, 28, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(100, 46, 8);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(57, 57, 8);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(68, 46, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(47, 41, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(10, 64, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(91, 69, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(65, 99, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(53, 76, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(50, 17, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(69, 44, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(35, 91, 8);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(35, 64, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(65, 31, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(29, 26, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(31, 88, 8);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(27, 62, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(21, 88, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(13, 99, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(97, 39, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(25, 97, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(19, 98, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(82, 58, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(64, 99, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(42, 18, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(30, 18, 8);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(20, 19, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(65, 68, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(32, 38, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(92, 14, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(42, 44, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(96, 14, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(68, 86, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(65, 100, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(91, 38, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(48, 77, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(46, 96, 8);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(9, 81, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(59, 44, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(46, 93, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(69, 29, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(83, 16, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(64, 57, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(41, 59, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(25, 78, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(34, 29, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(34, 19, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(36, 80, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(75, 45, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(41, 63, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(96, 66, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(98, 52, 8);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(91, 70, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(78, 21, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(19, 87, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(83, 71, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(62, 42, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(92, 36, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(57, 59, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(82, 36, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(85, 60, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(51, 89, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(36, 34, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(98, 97, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(57, 13, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(89, 65, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(25, 36, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(40, 50, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(33, 22, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(66, 100, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(35, 66, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(26, 67, 8);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(84, 61, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(34, 55, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(79, 23, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(73, 51, 8);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(45, 16, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(72, 53, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(31, 72, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(35, 63, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(88, 43, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(37, 94, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(64, 35, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(76, 53, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(41, 14, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(66, 76, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(96, 18, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(50, 48, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(40, 80, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(12, 69, 8);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(38, 36, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(15, 38, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(22, 83, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(5, 16, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(44, 91, 8);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(89, 88, 8);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(17, 61, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(82, 41, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(27, 59, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(38, 65, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(91, 47, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(100, 98, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(68, 35, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(11, 86, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(63, 14, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(24, 34, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(76, 56, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(11, 35, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(58, 89, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(49, 41, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(73, 18, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(59, 21, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(51, 70, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(58, 87, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(7, 38, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(89, 85, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(81, 55, 8);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(17, 17, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(61, 76, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(48, 39, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(45, 62, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(10, 89, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(35, 59, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(37, 35, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(60, 90, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(87, 63, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(43, 66, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(12, 61, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(87, 29, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(48, 43, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(89, 28, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(29, 19, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(46, 81, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(8, 32, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(36, 48, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(27, 52, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(41, 71, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(71, 72, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(34, 36, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(96, 28, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(38, 82, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(19, 58, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(96, 97, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(36, 37, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(85, 57, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(83, 62, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(91, 22, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(12, 17, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(34, 51, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(18, 26, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(29, 28, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(74, 84, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(82, 89, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(44, 56, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(72, 100, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(9, 97, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(3, 18, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(83, 51, 8);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(25, 85, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(68, 34, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(87, 69, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(23, 98, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(7, 71, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(51, 67, 8);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(61, 59, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(31, 75, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(5, 15, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(68, 69, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(62, 62, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(49, 75, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(87, 52, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(65, 76, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(41, 48, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(26, 47, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(14, 68, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(7, 50, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(13, 76, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(2, 37, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(81, 68, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(73, 65, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(96, 55, 8);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(42, 13, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(46, 37, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(25, 72, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(29, 69, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(63, 43, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(80, 97, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(36, 16, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(7, 56, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(88, 67, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(63, 28, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(88, 89, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(64, 38, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(11, 23, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(29, 13, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(47, 29, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(64, 40, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(50, 70, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(38, 91, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(48, 29, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(23, 25, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(19, 22, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(89, 68, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(27, 24, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(31, 55, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(62, 83, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(89, 16, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(2, 90, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(49, 87, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(73, 48, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(55, 62, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(68, 98, 8);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(52, 77, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(46, 44, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(54, 31, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(55, 94, 8);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(87, 89, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(7, 16, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(32, 90, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(52, 20, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(27, 32, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(20, 97, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(64, 29, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(66, 31, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(21, 77, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(49, 82, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(40, 98, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(45, 94, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(88, 54, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(19, 29, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(95, 25, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(31, 42, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(64, 69, 8);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(28, 77, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(83, 87, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(22, 48, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(47, 31, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(57, 43, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(8, 76, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(60, 36, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(53, 33, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(10, 46, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(70, 87, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(58, 76, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(69, 57, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(65, 21, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(24, 60, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(13, 48, 8);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(32, 66, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(66, 25, 8);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(20, 74, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(75, 16, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(85, 47, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(16, 24, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(5, 32, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(91, 59, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(9, 19, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(78, 77, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(51, 61, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(45, 87, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(31, 22, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(12, 32, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(72, 16, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(29, 71, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(11, 79, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(13, 63, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(84, 67, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(81, 38, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(64, 17, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(78, 50, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(34, 83, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(47, 21, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(4, 28, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(53, 74, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(77, 99, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(20, 20, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(42, 53, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(7, 19, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(90, 67, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(36, 50, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(90, 82, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(86, 71, 2);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(90, 13, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(59, 47, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(80, 75, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(32, 53, 4);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(90, 41, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(89, 21, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(52, 27, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(9, 58, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(55, 86, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(20, 60, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(40, 38, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(16, 58, 5);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(13, 64, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(62, 88, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(58, 88, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(62, 74, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(87, 93, 1);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(74, 69, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(78, 65, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(37, 85, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(77, 68, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(19, 49, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(1, 26, 8);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(11, 40, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(32, 68, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(41, 15, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(8, 44, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(32, 40, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(76, 27, 8);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(10, 39, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(89, 100, 6);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(44, 34, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(35, 13, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(17, 89, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(87, 24, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(100, 79, 3);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(61, 67, 8);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(45, 43, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(44, 98, 10);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(66, 18, 9);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(61, 91, 7);
INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId") VALUES(10, 13, 10);


/*******************************************************************************
   Create rules
********************************************************************************/

CREATE RULE "Difficulty_ForbidInsertion" AS ON INSERT
    TO "Difficulty"
    DO INSTEAD NOTHING;

CREATE RULE "Difficulty_ForbidUpdate" AS ON UPDATE
    TO "Difficulty"
    DO INSTEAD NOTHING;

CREATE RULE "Difficulty_ForbidDeletion" AS ON DELETE
    TO "Difficulty"
    DO INSTEAD NOTHING;

CREATE RULE "Role_ForbidInsertion" AS ON INSERT
    TO "Role"
    DO INSTEAD NOTHING;

CREATE RULE "Role_ForbidUpdate" AS ON UPDATE
    TO "Role"
    DO INSTEAD NOTHING;

CREATE RULE "Role_ForbidDeletion" AS ON DELETE
    TO "Role"
    DO INSTEAD NOTHING;

CREATE RULE "Country_ForbidInsertion" AS ON INSERT
    TO "Country"
    DO INSTEAD NOTHING;

CREATE RULE "Country_ForbidUpdate" AS ON UPDATE
    TO "Country"
    DO INSTEAD NOTHING;

CREATE RULE "Country_ForbidDeletion" AS ON DELETE
    TO "Country"
    DO INSTEAD NOTHING;

CREATE RULE "ProgrammingLanguage_ForbidInsertion" AS ON INSERT
    TO "ProgrammingLanguage"
    DO INSTEAD NOTHING;

CREATE RULE "ProgrammingLanguage_ForbidUpdate" AS ON UPDATE
    TO "ProgrammingLanguage"
    DO INSTEAD NOTHING;

CREATE RULE "ProgrammingLanguage_ForbidDeletion" AS ON DELETE
    TO "ProgrammingLanguage"
    DO INSTEAD NOTHING;

CREATE RULE "Result_ForbidInsertion" AS ON INSERT
    TO "Result"
    DO INSTEAD NOTHING;

CREATE RULE "Result_ForbidUpdate" AS ON UPDATE
    TO "Result"
    DO INSTEAD NOTHING;

CREATE RULE "Result_ForbidDeletion" AS ON DELETE
    TO "Result"
    DO INSTEAD NOTHING;

CREATE RULE "Tag_ForbidInsertion" AS ON INSERT
    TO "Tag"
    DO INSTEAD NOTHING;

CREATE RULE "Tag_ForbidUpdate" AS ON UPDATE
    TO "Tag"
    DO INSTEAD NOTHING;

CREATE RULE "Tag_ForbidDeletion" AS ON DELETE
    TO "Tag"
    DO INSTEAD NOTHING;

CREATE RULE "TagPrerequisite_ForbidInsertion" AS ON INSERT
    TO "TagPrerequisite"
    DO INSTEAD NOTHING;

CREATE RULE "TagPrerequisite_ForbidUpdate" AS ON UPDATE
    TO "TagPrerequisite"
    DO INSTEAD NOTHING;

CREATE RULE "TagPrerequisite_ForbidDeletion" AS ON DELETE
    TO "TagPrerequisite"
    DO INSTEAD NOTHING;

CREATE RULE "TagCategory_ForbidInsertion" AS ON INSERT
    TO "TagCategory"
    DO INSTEAD NOTHING;

CREATE RULE "TagCategory_ForbidUpdate" AS ON UPDATE
    TO "TagCategory"
    DO INSTEAD NOTHING;

CREATE RULE "TagCategory_ForbidDeletion" AS ON DELETE
    TO "TagCategory"
    DO INSTEAD NOTHING;

CREATE RULE "User_ForbidDeletion" AS ON DELETE
    TO "User"
    DO INSTEAD NOTHING;

CREATE RULE "Submission_ForbidDeletion" AS ON DELETE
    TO "Submission"
    DO INSTEAD NOTHING;

/*******************************************************************************
   Create User Functions
********************************************************************************/

CREATE OR REPLACE FUNCTION wasUserRegistered(userId INTEGER) RETURNS BOOLEAN AS $$
    BEGIN

        RETURN EXISTS (
            SELECT "DeletedAt"
            FROM "User"
            WHERE "UserId" = userId
        );

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION wasUserRegistered(userEmail EMAIL) RETURNS BOOLEAN AS $$
    BEGIN

        RETURN EXISTS (
            SELECT "DeletedAt"
            FROM "User"
            WHERE "Email" = userEmail
        );

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION wasUserRegistered(username TEXT) RETURNS BOOLEAN AS $$
    BEGIN

        RETURN EXISTS (
            SELECT "DeletedAt"
            FROM "User"
            WHERE "Username" = username
        );

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION isUserActive(userId INTEGER) RETURNS BOOLEAN AS $$
    BEGIN

        RETURN EXISTS (
            SELECT "DeletedAt"
            FROM "User"
            WHERE "UserId" = UserId
            AND "DeletedAt" IS NULL
        );

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION isUserActive(userEmail EMAIL) RETURNS BOOLEAN AS $$
    BEGIN

        RETURN EXISTS(
            SELECT "UserId"
            FROM "User"
            WHERE "Email" = userEmail
            AND "DeletedAt" IS NULL
        );

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION isUserActive(username TEXT) RETURNS BOOLEAN AS $$
    BEGIN

        RETURN EXISTS(
            SELECT "UserId"
            FROM "User"
            WHERE "Username" = username
            AND "DeletedAt" IS NULL
        );

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION isUserTemporarilyDeleted(userId INTEGER) RETURNS BOOLEAN AS $$
    BEGIN

        RETURN EXISTS (
            SELECT "DeletedAt"
            FROM "User"
            WHERE "UserId" = UserId
            AND "DeletedAt" > (NOW() - INTERVAL '1 day')
        );

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION isUserTemporarilyDeleted(userEmail EMAIL) RETURNS BOOLEAN AS $$
    BEGIN

        RETURN EXISTS(
            SELECT "UserId"
            FROM "User"
            WHERE "Email" = userEmail
            AND "DeletedAt" > (NOW() - INTERVAL '1 day')
        );

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION isUserTemporarilyDeleted(username TEXT) RETURNS BOOLEAN AS $$
    BEGIN

        RETURN EXISTS(
            SELECT "UserId"
            FROM "User"
            WHERE "Username" = username
            AND "DeletedAt" > (NOW() - INTERVAL '1 day')
        );

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION isUserPermanentlyDeleted(userId INTEGER) RETURNS BOOLEAN AS $$
    BEGIN

        RETURN EXISTS (
            SELECT "DeletedAt"
            FROM "User"
            WHERE "UserId" = userId
            AND "DeletedAt" <= (NOW() - INTERVAL '1 day')
        );

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION isUserPermanentlyDeleted(userEmail EMAIL) RETURNS BOOLEAN AS $$
    BEGIN

        RETURN EXISTS(
            SELECT "UserId"
            FROM "User"
            WHERE "Email" = userEmail
            AND "DeletedAt" <= (NOW() - INTERVAL '1 day')
        );

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION isUserPermanentlyDeleted(username TEXT) RETURNS BOOLEAN AS $$
    BEGIN

        RETURN EXISTS(
            SELECT "UserId"
            FROM "User"
            WHERE "Username" = username
            AND "DeletedAt" <= (NOW() - INTERVAL '1 day')
        );

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION isUserVerified(userId INTEGER) RETURNS BOOLEAN AS $$
    BEGIN

        RETURN EXISTS (
            SELECT *
            FROM "User"
            WHERE "UserId" = userId
            AND "DeletedAt" IS NULL
            AND "IsVerified" = TRUE
        );

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION isUserVerified(userEmail EMAIL) RETURNS BOOLEAN AS $$
    BEGIN

        RETURN EXISTS (
            SELECT *
            FROM "User"
            WHERE "Email" = userEmail
            AND "DeletedAt" IS NULL
            AND "IsVerified" = TRUE
        );

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION isUserVerified(username TEXT) RETURNS BOOLEAN AS $$
    BEGIN

        RETURN EXISTS (
            SELECT *
            FROM "User"
            WHERE "Username" = username
            AND "DeletedAt" IS NULL
            AND "IsVerified" = TRUE
        );

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION isEmailTaken(email EMAIL) RETURNS BOOLEAN AS $$
    BEGIN

        RETURN isUserActive(email) OR isUserTemporarilyDeleted(email);

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION isUsernameTaken(username TEXT) RETURNS BOOLEAN AS $$
    BEGIN

        RETURN isUserActive(username) OR isUserTemporarilyDeleted(username);

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION verifyUser(userid INTEGER) RETURNS VOID AS $$
    BEGIN
        UPDATE "User" SET "IsVerified" = TRUE WHERE "UserId" = userid;
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION verifyUser(username_ TEXT) RETURNS VOID AS $$
    BEGIN
        UPDATE "User" SET "IsVerified" = TRUE WHERE "Username" = username_;
    END;
$$ LANGUAGE plpgsql;

CREATE OR replace FUNCTION getUserId(username TEXT)
RETURNS INTEGER AS $$
BEGIN
  RETURN (SELECT "UserId" FROM "User" WHERE "Username" = username);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION createAccount(
    username TEXT,
    password TEXT,
    email EMAIL,
    countryName TEXT,
    notifyMe BOOLEAN DEFAULT False,
    firstName TEXT DEFAULT NULL,
    lastName TEXT DEFAULT NULL,
    organization TEXT DEFAULT NULL,
    roleName TEXT DEFAULT 'User'

) RETURNS VOID AS $$
    DECLARE

        roleId INTEGER;
        countryId INTEGER;

    BEGIN

        IF (isEmailTaken(email)) THEN
            RAISE EXCEPTION 'Email is already in use!'
                USING HINT = 'Please delete an account with this email first.';

        ELSEIF (isUsernameTaken(username)) THEN
            RAISE EXCEPTION 'Username is already in use!'
                USING HINT = 'Please try an another username.';

        END IF;

        roleId = (
            SELECT "RoleId"
            FROM "Role"
            WHERE "Name" = roleName
        );

        IF roleId IS NULL THEN
            RAISE EXCEPTION 'RoleId is invalid!'
                USING HINT = 'Please check the name of your role.';
        END IF;

        countryId = (
            SELECT "CountryId"
            FROM "Country"
            WHERE "Name" = countryName
        );

        IF countryId IS NULL THEN
            RAISE EXCEPTION 'CountryId is invalid!'
                USING HINT = 'Please check the name of your country.';
        END IF;

        INSERT INTO "User" ("RoleId", "CountryId", "ProblemsSolved", "LastSolved", "CreatedAt", "DeletedAt",
                            "Username", "PasswordHash", "Email", "FirstName", "LastName", "Organization",
                            "IsVerified", "NotifyMe")
                    VALUES (roleId, countryId, 0, NULL, NOW(), NULL,
                            username, MD5(password), email, firstName, lastName, organization,
                            false, notifyMe);

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION createAccount(
    username TEXT,
    password TEXT,
    email EMAIL,
    countryId INTEGER,
    notifyMe BOOLEAN DEFAULT False,
    firstName TEXT DEFAULT NULL,
    lastName TEXT DEFAULT NULL,
    organization TEXT DEFAULT NULL,
    roleName TEXT DEFAULT 'User'

) RETURNS VOID AS $$
    DECLARE

        roleId INTEGER;

    BEGIN

        IF (isEmailTaken(email)) THEN
            RAISE EXCEPTION 'Email is already in use!'
                USING HINT = 'Please delete an account with this email first.';

        ELSEIF (isUsernameTaken(username)) THEN
            RAISE EXCEPTION 'Username is already in use!'
                USING HINT = 'Please try an another username.';

        END IF;

        roleId = (
            SELECT "RoleId"
            FROM "Role"
            WHERE "Name" = roleName
        );

        IF roleId IS NULL THEN
            RAISE EXCEPTION 'RoleId is invalid!'
                USING HINT = 'Please check the name of your role.';
        END IF;

        INSERT INTO "User" ("RoleId", "CountryId", "ProblemsSolved", "LastSolved", "CreatedAt", "DeletedAt",
                            "Username", "PasswordHash", "Email", "FirstName", "LastName", "Organization",
                            "IsVerified", "NotifyMe")
                    VALUES (roleId, countryId, 0, NULL, NOW(), NULL,
                            username, MD5(password), email, firstName, lastName, organization,
                            false, notifyMe);

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION createAccount(
    username TEXT,
    password TEXT,
    email EMAIL,
    countryName TEXT,
    notifyMe BOOLEAN,
    firstName TEXT,
    lastName TEXT,
    organization TEXT,
    roleId INTEGER

) RETURNS VOID AS $$
    DECLARE

        countryId INTEGER;

    BEGIN

        IF (isEmailTaken(email)) THEN
            RAISE EXCEPTION 'Email is already in use!'
                USING HINT = 'Please delete an account with this email first.';

        ELSEIF (isUsernameTaken(username)) THEN
            RAISE EXCEPTION 'Username is already in use!'
                USING HINT = 'Please try an another username.';

        END IF;

        countryId = (
            SELECT "CountryId"
            FROM "Country"
            WHERE "Name" = countryName
        );

        IF countryId IS NULL THEN
            RAISE EXCEPTION 'CountryId is invalid!'
                USING HINT = 'Please check the name of your country.';
        END IF;

        INSERT INTO "User" ("RoleId", "CountryId", "ProblemsSolved", "LastSolved", "CreatedAt", "DeletedAt",
                            "Username", "PasswordHash", "Email", "FirstName", "LastName", "Organization",
                            "IsVerified", "NotifyMe")
                    VALUES (roleId, countryId, 0, NULL, NOW(), NULL,
                            username, MD5(password), email, firstName, lastName, organization,
                            false, notifyMe);

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION createAccount(
    username TEXT,
    password TEXT,
    email EMAIL,
    countryId INTEGER,
    notifyMe BOOLEAN,
    firstName TEXT,
    lastName TEXT,
    organization TEXT,
    roleId INTEGER

) RETURNS VOID AS $$
    BEGIN

        IF (isEmailTaken(email)) THEN
            RAISE EXCEPTION 'Email is already in use!'
                USING HINT = 'Please delete an account with this email first.';

        ELSEIF (isUsernameTaken(username)) THEN
            RAISE EXCEPTION 'Username is already in use!'
                USING HINT = 'Please try an another username.';

        END IF;

        INSERT INTO "User" ("RoleId", "CountryId", "ProblemsSolved", "LastSolved", "CreatedAt", "DeletedAt",
                            "Username", "PasswordHash", "Email", "FirstName", "LastName", "Organization",
                            "IsVerified", "NotifyMe")
                    VALUES (roleId, countryId, 0, NULL, NOW(), NULL,
                            username, MD5(password), email, firstName, lastName, organization,
                            false, notifyMe);

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION login(username TEXT, password TEXT) RETURNS BOOLEAN AS $$
    BEGIN

        IF isUserActive(username) = FALSE THEN
            RAISE EXCEPTION 'Username is invalid!'
                USING HINT = 'Please check if the user is active.';

        END IF;

        RETURN EXISTS (
            SELECT *
            FROM "User"
            WHERE "Username" = username
            AND "PasswordHash" = MD5(password)
        );

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION deleteAccount(userId INTEGER) RETURNS VOID AS $$
    BEGIN

        IF isUserActive(userId) = False THEN
            RAISE EXCEPTION 'UserId is invalid!'
                USING HINT = 'Please check if the user is active.';
        END IF;

        UPDATE "User"
            SET "DeletedAt" = NOW()
            WHERE "UserId" = userId;

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION restoreAccount(userId INTEGER) RETURNS VOID AS $$
    BEGIN

        IF wasUserRegistered(userId) = False THEN
            RAISE EXCEPTION 'UserId is invalid!'
                USING HINT = 'This user was never registered.';

        ELSEIF isUserPermanentlyDeleted(userId) = True THEN
            RAISE EXCEPTION 'UserId is invalid!'
                USING HINT = 'This account got deleted permanently.';

        ELSEIF isUserActive(userId) = True THEN
            RAISE EXCEPTION 'UserId is invalid!'
                USING HINT = 'This account is not deleted.';

        END IF;

        UPDATE "User"
            SET "DeletedAt" = NULL
            WHERE "UserId" = userId;

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION showRanking()
    RETURNS TABLE
    (
        "Index"             INTEGER,
        "User"              TEXT,
        "Solved Problems"    INTEGER
    )
AS $$
    BEGIN

        RETURN QUERY (
            SELECT (row_number() OVER ())::INTEGER, "Username", "ProblemsSolved"
            FROM "User"
            ORDER BY "ProblemsSolved" DESC, "LastSolved"
        );

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION User_ValidateInsert() RETURNS TRIGGER AS $$
    BEGIN
        IF NEW."ProblemsSolved" != 0 THEN
            RAISE EXCEPTION 'ProblemsSolved is invalid!'
                USING HINT = 'On registration user must have 0 problems solved!';

        ELSEIF NEW."Username" != OLD."Username" AND isUsernameTaken(NEW."Username") THEN
            RAISE EXCEPTION 'Username is invalid!'
                USING HINT = 'There exists an account with this username.';

        ELSEIF NEW."Email" != OLD."Email" AND isEmailTaken(NEW."Email") THEN
            RAISE EXCEPTION 'Email is invalid!'
                USING HINT = 'There exists an account with this email.';

        ELSEIF NEW."LastSolved" IS NOT NULL THEN
             RAISE EXCEPTION 'LastSolved is invalid!'
                USING HINT = 'New account could not solve any problem.';

        ELSEIF NEW."IsVerified" = True THEN
            RAISE EXCEPTION 'IsVerified is invalid!'
                USING HINT = 'Account cannot be verified by default.';

        END IF;

        NEW."CreatedAt" = NOW();
        NEW."DeletedAt" = NULL;

        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "User_ValidateInsert"
    BEFORE INSERT
    ON "User"
    FOR EACH ROW
EXECUTE PROCEDURE User_ValidateInsert();

CREATE OR REPLACE FUNCTION User_ValidateUpdate() RETURNS TRIGGER AS $$
    DECLARE

        userProblemsSolved INTEGER;

    BEGIN

        SELECT COUNT(DISTINCT("ProblemId"))
        INTO userProblemsSolved
        FROM "Submission"
        WHERE "UserId" = OLD."UserId" AND "ResultId" = 7;

        IF NEW."UserId" != OLD."UserId" THEN
            RAISE EXCEPTION 'UserId is invalid!'
                USING HINT = 'You cannot modify UserId value.';

        ELSEIF NEW."LastSolved" != OLD."LastSolved" THEN
            RAISE EXCEPTION 'LastSolved is invalid!'
                USING HINT = 'You cannot modify LastSolved value.';

        ELSEIF NEW."CreatedAt" != OLD."CreatedAt" THEN
            RAISE EXCEPTION 'CreatedAt is invalid!'
                USING HINT = 'You cannot modify CreatedAt value.';

        ELSEIF NEW."Username" != OLD."Username" AND isUsernameTaken(NEW."Username") THEN
            RAISE EXCEPTION 'Username is invalid!'
                USING HINT = 'There exists an account with this username.';

        ELSEIF NEW."Email" != OLD."Email" AND isEmailTaken(NEW."Email") THEN
            RAISE EXCEPTION 'Email is invalid!'
                USING HINT = 'There exists an account with this email.';

        ELSEIF NEW."DeletedAt" IS NOT NULL AND NEW."DeletedAt" NOT BETWEEN (NOW() - INTERVAL '1 second') AND NOW() THEN
            RAISE EXCEPTION 'DeletedAt is invalid!'
                USING HINT = 'Time of deletion must be equal NOW().';

        ELSEIF NEW."ProblemsSolved" != userProblemsSolved THEN
            RAISE EXCEPTION 'ProblemsSolved is invalid!'
                USING HINT = 'This value must represent an actual number of solved problems.';

        ELSEIF NEW."Email" != OLD."Email" THEN
            NEW."IsVerified" = False;

        END IF;

        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "User_ValidateUpdate"
    BEFORE UPDATE
    ON "User"
    FOR EACH ROW
EXECUTE PROCEDURE User_ValidateUpdate();


/*******************************************************************************
   Create Contest Functions
********************************************************************************/

CREATE OR REPLACE FUNCTION doesProblemExist(problemId INTEGER) RETURNS BOOLEAN AS $$
    BEGIN

        RETURN EXISTS (
            SELECT *
            FROM "Problem"
            WHERE "ProblemId" = problemId
        );

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION doesContestExist(id INTEGER) RETURNS BOOLEAN AS $$
    BEGIN

        RETURN EXISTS (
            SELECT *
            FROM "Contest"
            WHERE "ContestId" = id
        );

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION doesContestExist(name TEXT) RETURNS BOOLEAN AS $$
    BEGIN

        RETURN EXISTS (
            SELECT *
            FROM "Contest"
            WHERE "Name" = name
        );

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getContestId(name TEXT) RETURNS INTEGER AS $$
    BEGIN

        IF doesContestExist(name) = FALSE THEN
            RAISE EXCEPTION 'Contest name is invalid!'
                USING HINT = 'There is no contest with provided name.';

        END IF;

        RETURN (
            SELECT "ContestId"
            FROM "Contest"
            WHERE "Name" = name
        );

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE createContest (
    name TEXT,
    startTime TIMESTAMPTZ,
    duration INTERVAL,
    problems TEXT,
    authorId INTEGER,
    description TEXT DEFAULT NULL,
    isPublic BOOLEAN DEFAULT False,
    showLiveRanking BOOLEAN DEFAULT True

) AS $$
    DECLARE

        problemIdArr INTEGER[];
        problemId INTEGER;
        contestId INTEGER;

    BEGIN

        IF isUserVerified(authorId) = FALSE THEN
            RAISE EXCEPTION 'AuthorId is invalid!'
                USING HINT = 'Author is not a verified user.';

        END IF;

        problemIdArr = string_to_array(problems, ',');

        FOREACH problemId IN ARRAY problemIdArr LOOP
            IF doesProblemExist(problemId) = FALSE THEN
                RAISE EXCEPTION 'ProblemId is invalid!'
                    USING HINT = 'The problem you want to add is not in database.';
            END IF;
        END LOOP;

            INSERT INTO "Contest" ("AuthorId", "Name", "Description", "IsPublic",
                                   "ShowLiveRanking", "StartTime", "EndTime")
                           VALUES (authorId, name, description, isPublic,
                                   showLiveRanking, startTime, startTime + duration);

            contestId = getContestId(name);

            FOREACH problemId IN ARRAY problemIdArr LOOP
                INSERT INTO "ContestProblem" ("ContestId", "ProblemId")
                                      VALUES (contestId, problemId);
            END LOOP;

        COMMIT;

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION countContestProblems(contestId INTEGER) RETURNS INTEGER AS $$
    BEGIN

        RETURN (
            SELECT COUNT(*)
            FROM "ContestProblem"
            WHERE "ContestId" = contestId
        );

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Contest_ValidateInsert() RETURNS TRIGGER AS $$
    BEGIN

        IF NEW."StartTime" <= NOW() THEN
            RAISE EXCEPTION 'StartTime is invalid!'
                USING HINT = 'Contest should not start before creation.';
        END IF;

        RETURN NEW;

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Contest_ValidateInsertDeferred() RETURNS TRIGGER AS $$
    BEGIN

        IF countContestProblems(NEW."ContestId") = 0 THEN
            RAISE EXCEPTION 'Contest is invalid!'
                USING HINT = 'Contest should have at least one problem.';

        END IF;

        RETURN NEW;

    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "Contest_ValidateInsert"
    BEFORE INSERT
    ON "Contest"
    FOR EACH ROW
EXECUTE PROCEDURE Contest_ValidateInsert();

CREATE CONSTRAINT TRIGGER "Contest_ValidateInsertDeferred"
    AFTER INSERT
    ON "Contest"
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
EXECUTE PROCEDURE Contest_ValidateInsertDeferred();

CREATE OR REPLACE FUNCTION Contest_ValidateUpdate() RETURNS TRIGGER AS $$
    BEGIN

        IF NEW."ContestId" != OLD."ContestId" THEN
            RAISE EXCEPTION 'ContestId is invalid!'
                USING HINT = 'You cannot modify ContestId value.';

        ELSEIF NEW."AuthorId" != OLD."AuthorId" THEN
            RAISE EXCEPTION 'AuthorId is invalid!'
                USING HINT = 'You cannot modify AuthorId value.';

        ELSEIF NEW."StartTime" != OLD."StartTime" AND OLD."StartTime" <= NOW() THEN
            RAISE EXCEPTION 'StartTime is invalid!'
                USING HINT = 'You cannot modify StartTime after a contest has started.';

        ELSEIF NEW."StartTime" != OLD."StartTime" AND NEW."StartTime" <= NOW() THEN
            RAISE EXCEPTION 'StartTime is invalid!'
                USING HINT = 'StartTime must be in the future.';

        END IF;

        RETURN NEW;

    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "Contest_ValidateUpdate"
    BEFORE UPDATE
    ON "Contest"
    FOR EACH ROW
EXECUTE PROCEDURE Contest_ValidateUpdate();

CREATE OR REPLACE PROCEDURE deleteContest(contestId INTEGER) AS $$
    BEGIN

        DELETE FROM "ContestProblem"
            WHERE "ContestId" = contestId;

        DELETE FROM "ContestSubmission"
            WHERE "ContestId" = contestId;

        DELETE FROM "Registration"
            WHERE "ContestId" = contestId;

        DELETE FROM "Contest"
            WHERE "ContestId" = contestId;

    COMMIT;

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Contest_ValidateDelete() RETURNS TRIGGER AS $$
    BEGIN

        DELETE FROM "ContestProblem"
            WHERE "ContestId" = OLD."ContestId";

        DELETE FROM "ContestSubmission"
            WHERE "ContestId" = OLD."ContestId";

        DELETE FROM "Registration"
            WHERE "ContestId" = OLD."ContestId";

        RETURN NEW;

    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "Contest_ValidateDelete"
    BEFORE DELETE
    ON "Contest"
    FOR EACH ROW
EXECUTE PROCEDURE Contest_ValidateDelete();

CREATE OR REPLACE FUNCTION showSubmits(id INTEGER)
    RETURNS TABLE
    (
        "SubmissionId"          INTEGER,
        "UserId"                INTEGER,
        "ProblemId"             INTEGER,
        "ProgrammingLanguageId" INTEGER,
        "ResultName"            TEXT,
        "Points"                INTEGER,
        "SubmittedAt"           TIMESTAMPTZ,
        "Code"                  TEXT
    )
AS $$
    BEGIN

        RETURN QUERY (
            SELECT
                s."SubmissionId",
                s."UserId",
                s."ProblemId",
                s."ProgrammingLanguageId",
                r."Name",
                s."Points",
                s."SubmittedAt",
                s."Code"
            FROM "Submission" AS s
            INNER JOIN "Result" r USING ("ResultId")
            WHERE s."UserId" = id
            ORDER BY "SubmittedAt" DESC
        );

    END;
$$ LANGUAGE plpgsql;

/*******************************************************************************
   Create Contest View
********************************************************************************/

CREATE OR REPLACE VIEW showProblems AS (
            SELECT
                p."ProblemId"       AS "ProblemId",
                p."SourceId"        AS "SourceId",
                p."Difficulty"      AS "Difficulty",
                p."Quality"         AS "Quality",
                p."Name"            AS"Name",
                p."Url"             AS "Url",
                p."Path"            AS "Code",
                t."NameArray"       AS "TagName"
            FROM "Problem" AS p
            LEFT JOIN (SELECT
                            pt."ProblemId",
                            array_agg(tag."Name") AS "NameArray"
                        FROM "ProblemTag" pt
                        LEFT JOIN "Tag" tag USING ("TagId")
                        GROUP BY pt."ProblemId") t USING ("ProblemId")
            WHERE p."IsPublic" = TRUE
            ORDER BY "ProblemId"
);

/*******************************************************************************
   Test Contest
********************************************************************************/

-- SELECT * FROM "User";
-- SELECT createAccount('Ranz', 'rqgbh43', 'radek.m2001@gmail.com', 'Poland');
-- UPDATE "User" SET "IsVerified" = TRUE WHERE "UserId" = 1;
-- INSERT INTO "Source" ("Name") VALUES ('USACO');
-- SELECT * FROM "Source";
-- INSERT INTO "Problem" ("SourceId", "Difficulty", "Quality", "IsPublic", "Name")
--                VALUES (1, 3, 2, TRUE, 'Closest cow wins');
-- INSERT INTO "Problem" ("SourceId", "Difficulty", "Quality", "IsPublic", "Name")
--                VALUES (1, 5, 5, TRUE, 'Aggressive cows');
-- SELECT * FROM "Problem";
--
-- SELECT * FROM "Contest";
--
-- CALL createContest('POI Practice 2', NOW() + INTERVAL '1 hour', '2 hours', '2', 1);

/*******************************************************************************
   Create Registration Functions
********************************************************************************/

CREATE OR REPLACE FUNCTION register(userId INTEGER, contestId INTEGER) RETURNS VOID AS $$
    BEGIN

        IF isUserActive(userId) = FALSE THEN
            RAISE EXCEPTION 'UserId is invalid!'
                USING HINT = 'This user does not exist.';

        ELSEIF isUserVerified(userId) = FALSE THEN
            RAISE EXCEPTION 'UserId is invalid!'
                USING HINT = 'This user is not verified.';

        END IF;

        INSERT INTO "Registration" ("UserId", "ContestId", "RegisteredAt")
                            VALUES (userId, contestId, NOW());

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION isRegistered(contestId INTEGER, userId INTEGER) RETURNS BOOLEAN AS $$
    BEGIN

        RETURN EXISTS (
            SELECT *
            FROM "Registration"
            WHERE "ContestId" = contestId
            AND "UserId" = userId
        );

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION showRegistered(contestId INTEGER)
    RETURNS TABLE
    (
        "Username"          TEXT,
        "RegisteredAt"      TIMESTAMPTZ
    )
AS $$
    BEGIN

        RETURN QUERY (
            SELECT "User"."Username", "RegisteredAt"
            FROM "Registration"
            LEFT JOIN "User" ON "Registration"."UserId" = "User"."UserId"
            WHERE "Registration"."ContestId" = contestId
            ORDER BY "RegisteredAt"
        );

    END;
$$ LANGUAGE plpgsql;

/*******************************************************************************
   Create Submission Functions
********************************************************************************/

CREATE OR REPLACE FUNCTION doesProgrammingLanguageExist(programmingLanguageId INTEGER) RETURNS BOOLEAN AS $$
    BEGIN

        RETURN EXISTS (
            SELECT *
            FROM "ProgrammingLanguage"
            WHERE "ProgrammingLanguageId" = programmingLanguageId
        );

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getContestStartTime(contestId INTEGER) RETURNS TIMESTAMPTZ AS $$
    BEGIN

        IF doesContestExist(contestId) = FALSE THEN
            RAISE EXCEPTION 'ContestId is invalid!'
                USING HINT = 'The contest does not exist.';

        END IF;

        RETURN (
            SELECT "StartTime"
            FROM "Contest"
            WHERE "ContestId" = contestId
        );

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getContestEndTime(contestId INTEGER) RETURNS TIMESTAMPTZ AS $$
    BEGIN

        IF doesContestExist(contestId) = FALSE THEN
            RAISE EXCEPTION 'ContestId is invalid!'
                USING HINT = 'The contest does not exist.';

        END IF;

        RETURN (
            SELECT "EndTime"
            FROM "Contest"
            WHERE "ContestId" = contestId
        );

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE submit(
    userId INTEGER,
    problemId INTEGER,
    contestId INTEGER,
    programmingLanguageId INTEGER,
    code TEXT

) AS $$
    DECLARE

        submissionId INTEGER;

    BEGIN

        IF contestId IS NOT NULL AND doesContestExist(contestId) = FALSE THEN
            RAISE EXCEPTION 'ContestId is invalid!'
                USING HINT = 'The contest does not exist.';

        ELSEIF contestId IS NOT NULL AND isRegistered(contestId, userId) = FALSE THEN
            RAISE EXCEPTION 'You are not registered for this contest!'
                USING HINT = 'Register for the contest before you submit a solution.';

        ELSEIF contestId IS NOT NULL AND NOW() < getContestStartTime(contestId) THEN
            RAISE EXCEPTION 'SubmittedAt is invalid!'
                USING HINT = 'Wait for contest to start before you submit.';

        ELSEIF contestId IS NOT NULL AND getContestEndTime(contestId) < NOW() THEN
            RAISE EXCEPTION 'SubmittedAt is invalid!'
                USING HINT = 'You cannot submit solutions when contest has ended.';

        END IF;

        IF contestId IS NULL THEN

            INSERT INTO "Submission" ("UserId", "ProblemId", "ProgrammingLanguageId",
                                      "ResultId", "Points", "SubmittedAt", "Code")
            VALUES (userId, problemId, programmingLanguageId, 1, 0, NOW(), code);

        ELSE

            WITH submissionId AS (
                INSERT INTO "Submission" ("UserId", "ProblemId", "ProgrammingLanguageId",
                                          "ResultId", "Points", "SubmittedAt", "Code")
                VALUES (userId, problemId, programmingLanguageId, 1, 0, NOW(), code)
                RETURNING "SubmissionId"
            )
            INSERT INTO "ContestSubmission" ("ContestId", "SubmissionId")
            VALUES (contestId, submissionId);

        END IF;

        COMMIT;

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Submission_CheckInsert() RETURNS TRIGGER AS $$
    BEGIN

        IF isUserActive(NEW."UserId") = FALSE THEN
            RAISE EXCEPTION 'UserId is invalid!'
                USING HINT = 'This user does not exist.';

        ELSEIF isUserVerified(NEW."UserId") = FALSE THEN
            RAISE EXCEPTION 'UserId is invalid!'
                USING HINT = 'This user is not verified.';

        ELSEIF doesProblemExist(NEW."ProblemId") = FALSE THEN
            RAISE EXCEPTION 'ProblemId is invalid!'
                USING HINT = 'The problem does not exist.';

        ELSEIF doesProgrammingLanguageExist(NEW."ProgrammingLanguageId") = FALSE THEN
            RAISE EXCEPTION 'ProgrammingLanguageId is invalid!'
                USING HINT = 'This programming language does not exist.';

        END IF;

        NEW."ResultId" = 1;

        NEW."SubmittedAt" = NOW();

        NEW."Points" = 0;

        RETURN NEW;

    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "Submission_CheckInsert"
    BEFORE INSERT
    ON "Submission"
    FOR EACH ROW
EXECUTE PROCEDURE Submission_CheckInsert();

CREATE OR REPLACE FUNCTION Submission_CheckUpdate() RETURNS TRIGGER AS $$
    BEGIN

        IF NEW."SubmissionId" != OLD."SubmissionId" THEN
            RAISE EXCEPTION 'SubmissionId is invalid!'
                USING HINT = 'You cannot modify SubmissionId value.';

        ELSEIF NEW."UserId" != OLD."UserId" THEN
            RAISE EXCEPTION 'UserId is invalid!'
                USING HINT = 'You cannot modify UserId value.';

        ELSEIF NEW."ProblemId" != OLD."ProblemId" THEN
            RAISE EXCEPTION 'ProblemId is invalid!'
                USING HINT = 'You cannot modify ProblemId value.';

        ELSEIF NEW."ProgrammingLanguageId" != OLD."ProgrammingLanguageId" THEN
            RAISE EXCEPTION 'ProgrammingLanguageId is invalid!'
                USING HINT = 'You cannot modify ProgrammingLanguageId value.';

        ELSEIF NEW."SubmittedAt" != OLD."SubmittedAt" THEN
            RAISE EXCEPTION 'SubmittedAt is invalid!'
                USING HINT = 'You cannot modify SubmittedAt value.';

        ELSEIF NEW."Code" != OLD."Code" THEN
            RAISE EXCEPTION 'Code is invalid!'
                USING HINT = 'You cannot modify Code value.';

        END IF;

        IF NOT EXISTS(
            SELECT *
            FROM "Submission"
            WHERE "ProblemId" = NEW."ProblemId"
            AND "Points" = 100
        ) AND NEW."Points" = 100 THEN

            UPDATE "User"
            SET "LastSolved" = NOW()
            WHERE "UserId" = NEW."UserId";

            INSERT INTO "UserProblemsSolved" ("UserId", "ProblemId")
            VALUES (NEW."UserId", NEW."ProblemId");

        END IF;

        RETURN NEW;

    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "Submission_CheckUpdate"
    BEFORE UPDATE
    ON "Submission"
    FOR EACH ROW
EXECUTE PROCEDURE Submission_CheckUpdate();

/*******************************************************************************
   Test Submission
********************************************************************************/


/*******************************************************************************
   Create Problem Functions
********************************************************************************/

CREATE OR REPLACE FUNCTION sumProblemPoints(problemId INTEGER) RETURNS INTEGER AS $$
    DECLARE

        sum INTEGER;
        points INTEGER;

    BEGIN

        sum = 0;

        FOR points IN (
            SELECT "Points"
            FROM "Subtask"
            WHERE "ProblemId" = problemId
        ) LOOP
            sum = sum + points;
        END LOOP;

        RETURN points;

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE insertProblemTag(problemId INTEGER, tag TEXT) AS $$
    DECLARE

        tagArr TEXT[];

    BEGIN

        tagArr = string_to_array(tag, ',');

        INSERT INTO "ProblemTag" ("ProblemId", "TagId", "DifficultyId")
                          VALUES (problemId, tagArr[0], tagArr[1]);

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE addProblem(
    name TEXT,
    url TEXT,
    sourceId INTEGER,
    difficulty INTEGER,
    quality INTEGER,
    tags TEXT,
    hints TEXT,
    isPublic BOOLEAN DEFAULT TRUE,
    path TEXT DEFAULT NULL

) AS $$
    DECLARE

        tagArr INTEGER[];
        tag INTEGER;
        hintArr TEXT[];
        hint TEXT;
        problemId INTEGER;
        currPriority INTEGER;

    BEGIN

        currPriority = 0;

        INSERT INTO "Problem" ("SourceId", "Difficulty", "Quality",
                               "IsPublic", "Name", "Url", "Path")
                       VALUES ("SourceId", difficulty, quality,
                               isPublic, name, url, path)
                       RETURNING "ProblemId" INTO problemId;

        tagArr = string_to_array(tags, '|');

        FOREACH tag IN ARRAY tagArr LOOP
            CALL insertProblemTag(problemId, tag);
        END LOOP;

        hintArr = string_to_array(hints, '|');

        FOREACH hint IN ARRAY hintArr LOOP

            currPriority = currPriority + 1;

            INSERT INTO "Hint" ("ProblemId", "Priority", "Description")
                        VALUES (problemId, currPriority, hint);

        END LOOP;

        COMMIT;
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Problem_CheckInsert() RETURNS TRIGGER AS $$
    BEGIN

        IF sumProblemPoints(NEW."ProblemId") != 100 THEN
            RAISE EXCEPTION 'Subtasks are invalid!'
                USING HINT = 'Subtasks points do not sum up to 100.';

        END IF;

        RETURN NEW;

    END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER Problem_CheckInsert
    AFTER INSERT
    ON "Problem"
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
EXECUTE PROCEDURE Problem_CheckInsert();

CREATE OR REPLACE FUNCTION Problem_CheckUpdate() RETURNS TRIGGER AS $$
    BEGIN

        IF NEW."ProblemId" != OLD."ProblemId" THEN
            RAISE EXCEPTION 'ProblemId is invalid!'
                USING HINT = 'You cannot modify ProblemId value.';

        end if;

        RETURN NEW;

    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Problem_CheckUpdate
    BEFORE UPDATE
    ON "Problem"
    FOR EACH ROW
EXECUTE PROCEDURE Problem_CheckUpdate();

CREATE OR REPLACE FUNCTION Problem_CheckDelete() RETURNS TRIGGER AS $$
    BEGIN

        IF EXISTS (
            SELECT *
            FROM "ProblemTag"
            WHERE "ProblemId" = OLD."ProblemId"
        ) THEN
            RAISE EXCEPTION 'You did not delete this problem from ProblemTag!'
                USING HINT = 'You should delete this problem tags before deleting the problem itself.';

        ELSEIF EXISTS (
            SELECT *
            FROM "UserProblemsSolved"
            WHERE "ProblemId" = OLD."ProblemId"
        ) THEN
            RAISE EXCEPTION 'You did not delete this problem from UserProblemsSolved!'
                USING HINT = 'You should delete problems solved before deleting the problem itself.';

        ELSEIF EXISTS (
            SELECT *
            FROM "UserProblemHint"
            WHERE "ProblemId" = OLD."ProblemId"
        ) THEN
            RAISE EXCEPTION 'You did not delete this problem from UserProblemHint!'
                USING HINT = 'You should delete hints to this problem before deleting the problem itself.';

        ELSEIF EXISTS (
            SELECT *
            FROM "Hint"
            WHERE "ProblemId" = OLD."ProblemId"
        ) THEN
            RAISE EXCEPTION 'You did not delete this problem from Hint!'
                USING HINT = 'You should delete hints to this problem before deleting the problem itself.';

        ELSEIF EXISTS (
            SELECT *
            FROM "Subtask"
            LEFT JOIN "Test" ON "Subtask"."SubtaskId" = "Test"."SubtaskId"
            WHERE "ProblemId" = OLD."ProblemId"
        ) THEN
            RAISE EXCEPTION 'You did not delete this problem from Subtask or Test!'
                USING HINT = 'You should delete tests to this problem before deleting the problem itself.';

        ELSEIF EXISTS (
            SELECT *
            FROM "ContestProblem"
            WHERE "ProblemId" = OLD."ProblemId"
        ) THEN
            RAISE EXCEPTION 'You did not delete this problem from ContestProblem!'
                USING HINT = 'You should delete references to problem in ContestProblem before deleting the problem itself.';

        ELSEIF EXISTS (
            SELECT *
            FROM "Submission"
            LEFT JOIN "SubmissionTest" ON "Submission"."SubmissionId" = "SubmissionTest"."SubmissionId"
            LEFT JOIN "OfficialSolution" ON "Submission"."SubmissionId" = "OfficialSolution"."SubmissionId"
            WHERE "ProblemId" = OLD."ProblemId"
        ) THEN
            RAISE EXCEPTION 'You did not delete this problem from Submissions!'
                USING HINT = 'You should delete submissions to this problem before deleting the problem itself.';

        END IF;

        RETURN NEW;

    END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER Problem_CheckDelete
    AFTER DELETE
    ON "Problem"
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
EXECUTE PROCEDURE Problem_CheckDelete();


/*******************************************************************************
   User Accepted
********************************************************************************/

SELECT createAccount('Prot_wojt_asze2011'::TEXT, 'ls@6MD&P$CdgJ9f$2'::TEXT, 'prot.wojta12402@yahoo.com'::EMAIL, 'Poland'::TEXT, 'True'::BOOLEAN, 'Protazy'::TEXT, 'Wojtaszek'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Wie_ru494'::TEXT, 'J@Geo53@FASnA00&n8!Y'::TEXT, 'wiesrudzins@yahoo.com'::EMAIL, 'Poland'::TEXT);
SELECT createAccount('szargui2006'::TEXT, 'f!q8CTl68Ig650nSh6'::TEXT, 'szarlo.006@gmail.com'::EMAIL, 'Poland'::TEXT, 'True'::BOOLEAN, 'Szarlota'::TEXT, 'Sieradzki'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('radzi_Kraje'::TEXT, 'v6&iYV1!!!E9Y5X'::TEXT, 'radzi.kraj2022@gmail.com'::EMAIL, 'Poland'::TEXT, 'False'::BOOLEAN, 'Radzimir'::TEXT, 'Krajewski'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('angelin_Grz2000'::TEXT, 'ci#M2GG45RZ2!&q'::TEXT, 'angel._grz64634@hotmail.com'::EMAIL, 'Poland'::TEXT, 'True'::BOOLEAN, 'Angelina'::TEXT, 'Grzywacz'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('has_jawo_r'::TEXT, 'P$6shPti2%@7'::TEXT, 'h.j_aw1967@gmail.com'::EMAIL, 'Poland'::TEXT, 'True'::BOOLEAN, 'Hasan'::TEXT, 'Jaworski'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('_dveu2002'::TEXT, 'Fl5#Gz@H27pY'::TEXT, 'luiz.2002@yahoo.com'::EMAIL, 'Poland'::TEXT);
SELECT createAccount('daszo1997'::TEXT, 'Y0Dj#p12bPe33MEB35'::TEXT, 'd_sz05905@hotmail.com'::EMAIL, 'Poland'::TEXT, 'True'::BOOLEAN, 'Danko'::TEXT, 'Szot'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('selen1978'::TEXT, 'm8R@Mz9YCDA&Gj!lB'::TEXT, 'selen.17@outlook.com'::EMAIL, 'Poland'::TEXT, 'False'::BOOLEAN, 'Selena'::TEXT, 'Graczyk'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('roma_kuc1986'::TEXT, 'jbZ$8OG8'::TEXT, 'r.2961@gmail.com'::EMAIL, 'Poland'::TEXT);
SELECT createAccount('gisce40'::TEXT, 'ja3D#KGf!0h8mn'::TEXT, 'n_k_lime637@outlook.com'::EMAIL, 'Poland'::TEXT);
SELECT createAccount('ern_Stefansk1990'::TEXT, 'x2#MsX20tia'::TEXT, 'ernes.9088@outlook.com'::EMAIL, 'Poland'::TEXT, 'True'::BOOLEAN, 'Ernest'::TEXT, 'Stefański'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Bea_cza_jk1983'::TEXT, 'ba5&NQH!t'::TEXT, 'bea_cza1983@hotmail.com'::EMAIL, 'Canada'::TEXT, 'False'::BOOLEAN, 'Beat'::TEXT, 'Czajka'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Franci_tark12'::TEXT, 'iA0X%n26k5t'::TEXT, 'franciszk_tark1982@hotmail.com'::EMAIL, 'Poland'::TEXT, 'False'::BOOLEAN, 'Franciszka'::TEXT, 'Tarka'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Jon_ga'::TEXT, 'si&VG0nz3MsO2003!@G'::TEXT, 'j_1975@gmail.com'::EMAIL, 'Poland'::TEXT, 'True'::BOOLEAN, 'Jonatan'::TEXT, 'Gazda'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Radomirzawis'::TEXT, 'Gx#Gz0t&%'::TEXT, 'radomi_zaw4054@yahoo.com'::EMAIL, 'Poland'::TEXT);
SELECT createAccount('Boro1999'::TEXT, 'j!4zCHPkj@6g'::TEXT, 'u_1999@hotmail.com'::EMAIL, 'Poland'::TEXT, 'False'::BOOLEAN, 'Uta'::TEXT, 'Boroń'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Mojmik67'::TEXT, 'JT6i!x8$HK0bu'::TEXT, 'mojmier.kupi1983@yahoo.com'::EMAIL, 'Poland'::TEXT, 'True'::BOOLEAN, 'Mojmierz'::TEXT, 'Kupiec'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('bogus_055'::TEXT, 'uo!3XXdUEdhs#il'::TEXT, 'bogu_zar_emb1@gmail.com'::EMAIL, 'Poland'::TEXT, 'False'::BOOLEAN, 'Boguslaw'::TEXT, 'Zaremba'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('lilian_borko65433'::TEXT, 'g5@KGrd8n$!%!'::TEXT, 'lili__bor_kow1989@outlook.com'::EMAIL, 'Poland'::TEXT, 'True'::BOOLEAN, 'Liliana'::TEXT, 'Borkowski'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Ange_rnuo2016'::TEXT, 'hbUA!6iEYf'::TEXT, 'ac341@yahoo.com'::EMAIL, 'Poland'::TEXT);
SELECT createAccount('albinKub1976'::TEXT, 'IA6wp$z!@@0t&8@'::TEXT, 'albin.ku2@hotmail.com'::EMAIL, 'Poland'::TEXT);
SELECT createAccount('Gawe_Izd_eb2003'::TEXT, 'r2$CwV&LObe#e8I'::TEXT, 'gawe.i_z2003@outlook.com'::EMAIL, 'Poland'::TEXT, 'True'::BOOLEAN, 'Gaweł'::TEXT, 'Izdebski'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('mi__Szymc1993'::TEXT, 'w6$ZIh2j&f'::TEXT, 'mik.szym3@gmail.com'::EMAIL, 'Poland'::TEXT);
SELECT createAccount('Niradamczewsk'::TEXT, 'op8%UF$0&#f$#gp$'::TEXT, 'niradamcz4949@gmail.com'::EMAIL, 'Poland'::TEXT, 'True'::BOOLEAN, 'Nira'::TEXT, 'Adamczewski'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('__Bwhvya2000'::TEXT, 'zl$1PDq#$1nBh#0#k'::TEXT, 'mari_2@gmail.com'::EMAIL, 'Poland'::TEXT);
SELECT createAccount('Szarlobo2738'::TEXT, 'Q1a!mE@8'::TEXT, 's.bo2020@yahoo.com'::EMAIL, 'Poland'::TEXT, 'False'::BOOLEAN, 'Szarlota'::TEXT, 'Boroń'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Wespazjapel34'::TEXT, 'f$Qe0Rte@W!KYX&dP'::TEXT, 'wespazja_p4@yahoo.com'::EMAIL, 'Poland'::TEXT);
SELECT createAccount('Mikjch2008'::TEXT, 'Sn!0nAZO'::TEXT, 'm.mi_kola_j9336@yahoo.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Marianna'::TEXT, 'Mikołajczak'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Dargosla_66'::TEXT, 'j%Rs9F7K15y6Ue34F%'::TEXT, 'dargos.p2570@outlook.com'::EMAIL, 'Poland'::TEXT, 'True'::BOOLEAN, 'Dargosława'::TEXT, 'Porębski'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Benedykt_l_as1996'::TEXT, 'D4L$ta!F2'::TEXT, 'bene_01837@gmail.com'::EMAIL, 'Canada'::TEXT, 'False'::BOOLEAN, 'Benedykta'::TEXT, 'Lasota'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Zane_ko_mo_r2017'::TEXT, 'lU8!aS3x5%'::TEXT, 'k014@outlook.com'::EMAIL, 'Poland'::TEXT, 'False'::BOOLEAN, 'Żaneta'::TEXT, 'Komorowski'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Flo_Oilbte1982'::TEXT, 'xMuV7$$T5!@g'::TEXT, 'florian.osso36@outlook.com'::EMAIL, 'Canada'::TEXT, 'True'::BOOLEAN, 'Floriana'::TEXT, 'Ossowski'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('chwaliw7'::TEXT, 'NfK@p8YVQqp%x1v'::TEXT, 'chwalisla_2008@yahoo.com'::EMAIL, 'Poland'::TEXT);
SELECT createAccount('Ol_loren1995'::TEXT, 'VR%y1aTU$hw$&Fg&'::TEXT, 'o.lor1995@hotmail.com'::EMAIL, 'Poland'::TEXT, 'False'::BOOLEAN, 'Ola'::TEXT, 'Lorenc'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('izthd26'::TEXT, 'yCq@3Ln@c8@!ylWsU&'::TEXT, 'bogus.za6019@hotmail.com'::EMAIL, 'Poland'::TEXT, 'True'::BOOLEAN, 'Bogusław'::TEXT, 'Zaremba'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('zygfBiel2012'::TEXT, 'r3#qCB!5ideN@%@'::TEXT, 'zygfrydbie_l583@hotmail.com'::EMAIL, 'Poland'::TEXT, 'True'::BOOLEAN, 'Zygfryda'::TEXT, 'Bielecki'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('chwdz'::TEXT, 'i!pMF78Y0B8!2Es'::TEXT, 'c_d_zi2013@outlook.com'::EMAIL, 'Poland'::TEXT);
SELECT createAccount('RobeStr_z5930'::TEXT, 'tN0K@pq&06'::TEXT, 'robest@gmail.com'::EMAIL, 'Poland'::TEXT);
SELECT createAccount('Ola_iasx0454'::TEXT, 'h1IDz#oW!AWyJ!2'::TEXT, 'o.p2018@hotmail.com'::EMAIL, 'Poland'::TEXT, 'False'::BOOLEAN, 'Olaf'::TEXT, 'Pawlak'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('mar_lip9873'::TEXT, 'd&4VbS$QKdB#i37u1FiT'::TEXT, 'marci.li@outlook.com'::EMAIL, 'Poland'::TEXT, 'False'::BOOLEAN, 'Marcin'::TEXT, 'Lipka'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('wisl3155'::TEXT, 'b@W7Uablaq$Doy9aJ47'::TEXT, 'wislaw.2017@gmail.com'::EMAIL, 'Poland'::TEXT);
SELECT createAccount('Banas31'::TEXT, 'tSzB%94a'::TEXT, 'k.bana6@gmail.com'::EMAIL, 'Poland'::TEXT, 'False'::BOOLEAN, 'Kiara'::TEXT, 'Banaszak'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('SlWojt_a5'::TEXT, 'GM!cz7K3l68d3'::TEXT, 's.w1997@outlook.com'::EMAIL, 'Poland'::TEXT, 'False'::BOOLEAN, 'Sław'::TEXT, 'Wojtas'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('MurWie_cz1993'::TEXT, 'wK%9iI453&&'::TEXT, 'murawi1993@gmail.com'::EMAIL, 'Poland'::TEXT, 'False'::BOOLEAN, 'Murat'::TEXT, 'Wieczorek'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Kaj_palu_c1998'::TEXT, 'qy8%CC1AM@%O$%N53'::TEXT, 'kajpa_l1998@gmail.com'::EMAIL, 'Poland'::TEXT, 'False'::BOOLEAN, 'Kaja'::TEXT, 'Paluch'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('romwil64489'::TEXT, 'i!4AjW4V$#eVZ'::TEXT, 'roma.wilcze82902@gmail.com'::EMAIL, 'Poland'::TEXT);
SELECT createAccount('jessic_War8'::TEXT, 'wI!w9LYKWp03'::TEXT, 'jessicwarze72366@gmail.com'::EMAIL, 'Poland'::TEXT);
SELECT createAccount('edwa_C_isz2006'::TEXT, 'd6!cOO0T#&!6Hg'::TEXT, 'e_ci046@outlook.com'::EMAIL, 'Poland'::TEXT, 'False'::BOOLEAN, 'Edward'::TEXT, 'Ciszewski'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Wi_li_nsk1995'::TEXT, 'x%3gDLK4$&##1D#6%&Y'::TEXT, 'o_wil_i_1995@outlook.com'::EMAIL, 'Poland'::TEXT);
SELECT createAccount('Blaze_1999'::TEXT, 'cp@PM50M6433x'::TEXT, 'bla_k0@yahoo.com'::EMAIL, 'Poland'::TEXT);
SELECT createAccount('Dzwonim_Zare2002'::TEXT, 'q3Cl#Y1&&#'::TEXT, 'dzwonimier.z2002@hotmail.com'::EMAIL, 'Poland'::TEXT, 'True'::BOOLEAN, 'Dzwonimierz'::TEXT, 'Zaremba'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('juPoto2103'::TEXT, 'Jmu7!WB@!o720'::TEXT, 'j.potock@hotmail.com'::EMAIL, 'United States'::TEXT);
SELECT createAccount('boguMicha1996'::TEXT, 'n%5QEd1#S#Kmy'::TEXT, 'bogus_m1996@yahoo.com'::EMAIL, 'Poland'::TEXT, 'True'::BOOLEAN, 'Bogusz'::TEXT, 'Michalczyk'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('kozio2000'::TEXT, 'Iz@0lQ7576!'::TEXT, 'doroslkoz2000@yahoo.com'::EMAIL, 'Poland'::TEXT, 'False'::BOOLEAN, 'Dorosława'::TEXT, 'Kozioł'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Sebastia_W_esolo3080'::TEXT, 'v5j&JY&h9D05%lgE#x'::TEXT, 'sebast_wes1991@hotmail.com'::EMAIL, 'Poland'::TEXT);
SELECT createAccount('AidSzkudl_are2008'::TEXT, 'PG&sl6EBC1c$&&Rq0'::TEXT, 'a.szkudlar2008@outlook.com'::EMAIL, 'Poland'::TEXT, 'False'::BOOLEAN, 'Aida'::TEXT, 'Szkudlarek'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Gaqaqpv2010'::TEXT, 'y6pO@JJ#9fr'::TEXT, 'amin.gac2010@gmail.com'::EMAIL, 'Poland'::TEXT, 'False'::BOOLEAN, 'Amina'::TEXT, 'Gacek'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('ambrozpila2003'::TEXT, 'qa!3IYb5!f&'::TEXT, 'ambrozpilarczy2003@hotmail.com'::EMAIL, 'Canada'::TEXT);
SELECT createAccount('_sobansk09'::TEXT, 'c&ABj8c5!2P%ku#'::TEXT, 'kamil_soba1997@gmail.com'::EMAIL, 'Poland'::TEXT, 'True'::BOOLEAN, 'Kamila'::TEXT, 'Sobański'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Anzelbzx886'::TEXT, 'ql1AQ#YZe4NiW$q'::TEXT, 'anzel._pa_ne@gmail.com'::EMAIL, 'Poland'::TEXT, 'False'::BOOLEAN, 'Anzelm'::TEXT, 'Panek'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('ales_K_o_b1969'::TEXT, 'xF2Z%cumP'::TEXT, 'alesj.ko1969@hotmail.com'::EMAIL, 'Poland'::TEXT);
SELECT createAccount('celinKuch2002'::TEXT, 'w7J!nQOGKl@fTf35JQim'::TEXT, 'celin.kuc_h48214@hotmail.com'::EMAIL, 'Poland'::TEXT);
SELECT createAccount('Otn_Piwowar277'::TEXT, 'd1y$CQ18d$S@LD'::TEXT, 'otnie56175@gmail.com'::EMAIL, 'Poland'::TEXT, 'False'::BOOLEAN, 'Otniel'::TEXT, 'Piwowarczyk'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('bozen_Bie2017'::TEXT, 'k%1aEM66kCaSc5o1@&'::TEXT, 'bozenn2017@gmail.com'::EMAIL, 'Poland'::TEXT, 'False'::BOOLEAN, 'Bożenna'::TEXT, 'Biernacki'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Aleksand_szy'::TEXT, 'G9@uUtRa@!9GmU$mR'::TEXT, 'aleksandeszymans58@gmail.com'::EMAIL, 'Poland'::TEXT);
SELECT createAccount('Mir_Ciesi_e_ls1999'::TEXT, 'kn0XG&Fpi5uM23!7!&##'::TEXT, 'miro.1999@hotmail.com'::EMAIL, 'Poland'::TEXT);
SELECT createAccount('kam_ka2006'::TEXT, 'QzP#5kId'::TEXT, 'kamka2006@outlook.com'::EMAIL, 'Poland'::TEXT);
SELECT createAccount('metodpi2021'::TEXT, 'uhP8$FklfKzu3'::TEXT, 'meto.pie2021@yahoo.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Metody'::TEXT, 'Piech'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('teodorKoto36'::TEXT, 'n4!iBNvp5'::TEXT, 'teodorkoto1995@outlook.com'::EMAIL, 'Poland'::TEXT, 'True'::BOOLEAN, 'Teodora'::TEXT, 'Kotowski'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Athen_morr1996'::TEXT, 'vn%7KXB@4h8'::TEXT, 'athen_mor_r4850@outlook.com'::EMAIL, 'Australia'::TEXT, 'False'::BOOLEAN, 'Athena'::TEXT, 'Morris'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('emil_Wil7'::TEXT, 'r4!LMjZW81'::TEXT, 'emiliwilkin9194@outlook.com'::EMAIL, 'Australia'::TEXT);
SELECT createAccount('ruebzias2001'::TEXT, 'r7!UqA#$!Cb7!u1#%'::TEXT, 'ruebe_coo2001@yahoo.com'::EMAIL, 'United Kingdom'::TEXT, 'True'::BOOLEAN, 'Rueben'::TEXT, 'Cook'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('imogecha2018'::TEXT, 'uU4@Je!#!41C&l'::TEXT, 'imog2018@outlook.com'::EMAIL, 'United Kingdom'::TEXT);
SELECT createAccount('dott_ncaoo6276'::TEXT, 'b$2MLlldL2I'::TEXT, 'd_flem_i2020@gmail.com'::EMAIL, 'United Kingdom'::TEXT, 'False'::BOOLEAN, 'Dotty'::TEXT, 'Fleming'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('_La_wslal3'::TEXT, 'a@mK9DJL@4&7hxEY$!!'::TEXT, 'roga.3977@gmail.com'::EMAIL, 'Canada'::TEXT);
SELECT createAccount('raphae_Hu_s2'::TEXT, 'EX%4hb!hGYRv4m2'::TEXT, 'rapha.hus2014@yahoo.com'::EMAIL, 'Canada'::TEXT);
SELECT createAccount('fredri_Ril44'::TEXT, 'z#FnE4@5k$91n6@'::TEXT, 'fredricrile3025@outlook.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Fredrick'::TEXT, 'Riley'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('kiimfqh554'::TEXT, 'j7E!oC&Lm%x$kmu4'::TEXT, 'audr_kin62@gmail.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Audrey'::TEXT, 'King'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('_mccart67484'::TEXT, 'r3hV%TmCu'::TEXT, 'r__m1975@hotmail.com'::EMAIL, 'Australia'::TEXT, 'False'::BOOLEAN, 'Rory'::TEXT, 'Mccarthy'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('nylMa75'::TEXT, 'Bu1Uz@1&%PhB!3#@1#!'::TEXT, 'nyl_1990@gmail.com'::EMAIL, 'United States'::TEXT);
SELECT createAccount('Fri_babz1979'::TEXT, 'qH3j@MJ4r1R%P'::TEXT, 'fridbrooke096@hotmail.com'::EMAIL, 'Australia'::TEXT);
SELECT createAccount('Aro_graha2019'::TEXT, 'E6&gmLSuVPF%36'::TEXT, 'arona_2019@yahoo.com'::EMAIL, 'United Kingdom'::TEXT, 'True'::BOOLEAN, 'Aronas'::TEXT, 'Graham'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('juli_Graha2000'::TEXT, 'w%tCG8#UF#K!F'::TEXT, 'juliettgraha2000@gmail.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Juliette'::TEXT, 'Graham'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('HenrieGardn'::TEXT, 'a!U8dF%I#0N28C'::TEXT, 'henriettgar_dn1984@gmail.com'::EMAIL, 'New Zealand'::TEXT, 'True'::BOOLEAN, 'Henrietta'::TEXT, 'Gardner'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Den_faulkn'::TEXT, 'su7@MS%h4pyvGfM'::TEXT, 'denn__f_a10842@yahoo.com'::EMAIL, 'Ireland'::TEXT, 'True'::BOOLEAN, 'Denny'::TEXT, 'Faulkner'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('moha_P'::TEXT, 'wl@TF58Bvn@q4&Q'::TEXT, 'm_pra2014@gmail.com'::EMAIL, 'United Kingdom'::TEXT, 'True'::BOOLEAN, 'Mohammad'::TEXT, 'Pratt'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('raf_spen1965'::TEXT, 'ls0KU&H&1j'::TEXT, 'raf1965@outlook.com'::EMAIL, 'United Kingdom'::TEXT, 'True'::BOOLEAN, 'Rafi'::TEXT, 'Spence'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('myfye7314'::TEXT, 'sC@A6g14Il@'::TEXT, 'lill.mi2000@hotmail.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Lilly'::TEXT, 'Miller'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('EmFros2012'::TEXT, 'ThD&j9vesQr!d9y&23!4'::TEXT, 'emil_f_r2012@hotmail.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Emily'::TEXT, 'Frost'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('andrEdwar75617'::TEXT, 'q&Cn1CX4IjX#l$X!g'::TEXT, 'andreaedw5@outlook.com'::EMAIL, 'United Kingdom'::TEXT, 'True'::BOOLEAN, 'Andreas'::TEXT, 'Edwards'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('PresSheph2001'::TEXT, 'M1$ckH72S&3Wc#bl413'::TEXT, 'presto._shep3836@gmail.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Preston'::TEXT, 'Shepherd'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('thei_Barb2019'::TEXT, 'f#D2uFCV!lJ'::TEXT, 'thei.ba2019@gmail.com'::EMAIL, 'New Zealand'::TEXT, 'False'::BOOLEAN, 'Theia'::TEXT, 'Barber'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('EmiWood36775'::TEXT, 'C&y5UbG74Q9!&@$c45%B'::TEXT, 'emi_w_o_od4418@outlook.com'::EMAIL, 'Bahamas'::TEXT, 'True'::BOOLEAN, 'Emir'::TEXT, 'Woods'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('karbzkzuv0'::TEXT, 'I&mn2SXJ6uXsN'::TEXT, 'kar.bail_e2001@gmail.com'::EMAIL, 'New Zealand'::TEXT, 'True'::BOOLEAN, 'Kara'::TEXT, 'Bailey'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Tob_rnouii1982'::TEXT, 'sAY#9aeCAZ7J!h$S3z%'::TEXT, 'tob_rit1982@gmail.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Toby'::TEXT, 'Ritchie'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('sonCl12'::TEXT, 'T$oy3L&oB7%8'::TEXT, 'sonn.clayt1995@outlook.com'::EMAIL, 'Australia'::TEXT, 'False'::BOOLEAN, 'Sonny'::TEXT, 'Clayton'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('cameroSi_m_pso2012'::TEXT, 'uJW@p33!b%#9i@%0h&a'::TEXT, 'camero_sim_p1@yahoo.com'::EMAIL, 'Canada'::TEXT, 'True'::BOOLEAN, 'Cameron'::TEXT, 'Simpson'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('a__Axgigo'::TEXT, 'v!oS0T$4bQ5!!eRe!'::TEXT, 'aa1985@hotmail.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Abu'::TEXT, 'Archer'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('eth_sa1995'::TEXT, 'BxS#a3k!#TY!@6'::TEXT, 'ethas66@gmail.com'::EMAIL, 'Australia'::TEXT, 'False'::BOOLEAN, 'Ethan'::TEXT, 'Sanders'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('ostho2015'::TEXT, 'z&Q4Xp3Ll!'::TEXT, 'oth04186@gmail.com'::EMAIL, 'New Zealand'::TEXT, 'False'::BOOLEAN, 'Osian'::TEXT, 'Thorpe'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Solomcampb_e52'::TEXT, 'jmW5$Fdi$m$07'::TEXT, 'solom.cam2006@outlook.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Solomon'::TEXT, 'Campbell'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('carSwee2005'::TEXT, 'FCu#t6g9a@%&lhD9&!Z9'::TEXT, 'carl.2005@hotmail.com'::EMAIL, 'Jamaica'::TEXT);
SELECT createAccount('ariellGar2004'::TEXT, 'cgD!T3#x%A2!'::TEXT, 'ariel.ga_rdi2004@hotmail.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Arielle'::TEXT, 'Gardiner'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Ver_go1979'::TEXT, 'gJd@4D&tv'::TEXT, 'ver.goul7994@hotmail.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Vera'::TEXT, 'Gould'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('huedxph1993'::TEXT, 'b5!HtK&Ol5S%l3@9WZUr'::TEXT, 'kaide_h_unt@gmail.com'::EMAIL, 'United Kingdom'::TEXT);
SELECT createAccount('jemim_Clayto1992'::TEXT, 'EK$6wbqA#25@!0@3'::TEXT, 'jemima.c9846@hotmail.com'::EMAIL, 'United Kingdom'::TEXT, 'True'::BOOLEAN, 'Jemimah'::TEXT, 'Clayton'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('farr_johns1975'::TEXT, 'b$HOi5z8KA1'::TEXT, 'farraj_oh_nsto21877@gmail.com'::EMAIL, 'Australia'::TEXT, 'True'::BOOLEAN, 'Farrah'::TEXT, 'Johnston'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('osiaggjoq2020'::TEXT, 'o!2nPO0U&$8'::TEXT, 'o.n2020@outlook.com'::EMAIL, 'Barbados'::TEXT, 'False'::BOOLEAN, 'Osian'::TEXT, 'Noble'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Eshpbkzn66'::TEXT, 'wV3kX@@FK'::TEXT, 'esha.048@yahoo.com'::EMAIL, 'Canada'::TEXT, 'False'::BOOLEAN, 'Eshaal'::TEXT, 'Poole'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('esmaHun1999'::TEXT, 'fQ&Qs0U75!Xo'::TEXT, 'esma.h1999@gmail.com'::EMAIL, 'Canada'::TEXT);
SELECT createAccount('Tobi_Sutherla'::TEXT, 'xBAm@8G3I@%Y6$W!7&t0'::TEXT, 't.s1@outlook.com'::EMAIL, 'United Kingdom'::TEXT, 'False'::BOOLEAN, 'Tobias'::TEXT, 'Sutherland'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Wini_foste81'::TEXT, 'a1Wm&P3&JW3'::TEXT, 'w.fos2017@gmail.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Winifred'::TEXT, 'Foster'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('arhayaoic1979'::TEXT, 'c2sH$G&T5#I$WM47N'::TEXT, 'a.chamber1979@outlook.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Arham'::TEXT, 'Chambers'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('_Millvqa2017'::TEXT, 'z3QF@afeG!R%yT&D&0L'::TEXT, 'jaxso_66@outlook.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Jaxson'::TEXT, 'Mills'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('aydeHi0029'::TEXT, 'U@Gzs0NDw@2652p1h$$'::TEXT, 'a_h2004@gmail.com'::EMAIL, 'United Kingdom'::TEXT);
SELECT createAccount('edw_bayar'::TEXT, 'r$c1GQkV4JG!EryS'::TEXT, 'edwi.2002@gmail.com'::EMAIL, 'United States'::TEXT);
SELECT createAccount('Kars_wee8'::TEXT, 'geXF!12eYy8hwVA24'::TEXT, 'karsw2019@outlook.com'::EMAIL, 'Bahamas'::TEXT, 'True'::BOOLEAN, 'Kara'::TEXT, 'Sweeney'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Nat_npudm6529'::TEXT, 'Icq!3M&iF'::TEXT, 'nata_tho1993@gmail.com'::EMAIL, 'New Zealand'::TEXT, 'True'::BOOLEAN, 'Natan'::TEXT, 'Thompson'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Hen_butle2015'::TEXT, 'z2#EfG@Qvi2!'::TEXT, 'h_2015@gmail.com'::EMAIL, 'United Kingdom'::TEXT, 'False'::BOOLEAN, 'Henley'::TEXT, 'Butler'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Joa_chad_w2011'::TEXT, 'F1ag#TP!3629cjfG'::TEXT, 'joann.ch5@yahoo.com'::EMAIL, 'Australia'::TEXT, 'False'::BOOLEAN, 'Joanna'::TEXT, 'Chadwick'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('M_ackegu1997'::TEXT, 'lK%4Yue%&e$5V&&q5ZF'::TEXT, 'rena.macken1997@gmail.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Renae'::TEXT, 'Mackenzie'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Szymo_hoo9'::TEXT, 'x5&BpIzh10Rfs'::TEXT, 's_87@hotmail.com'::EMAIL, 'United Kingdom'::TEXT, 'False'::BOOLEAN, 'Szymon'::TEXT, 'Hooper'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('_ahuwhd'::TEXT, 'ab4A&XUQ'::TEXT, 'kimberl_a2002@outlook.com'::EMAIL, 'United Kingdom'::TEXT, 'False'::BOOLEAN, 'Kimberley'::TEXT, 'Ahmed'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('cassiWil2022'::TEXT, 'v1e$IWiD!#&8Y5&'::TEXT, 'cass.w_i_ls_o58493@gmail.com'::EMAIL, 'Canada'::TEXT, 'True'::BOOLEAN, 'Cassidy'::TEXT, 'Wilson'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('_naqco1986'::TEXT, 'A@o8gER53'::TEXT, 'tn393@yahoo.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Teddie'::TEXT, 'Nash'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Lol_richar1995'::TEXT, 'y1!PVbJ%$UeR'::TEXT, 'lr1995@hotmail.com'::EMAIL, 'United States'::TEXT);
SELECT createAccount('walter2012'::TEXT, 'fr7CO@Z!!JI@67'::TEXT, 'juli3511@outlook.com'::EMAIL, 'Dominica'::TEXT);
SELECT createAccount('Zofigl1987'::TEXT, 's%0fPZX1O@F$ive'::TEXT, 'zofi.gl1987@gmail.com'::EMAIL, 'Australia'::TEXT, 'True'::BOOLEAN, 'Zofia'::TEXT, 'Glover'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Arc_pwvq'::TEXT, 'c&ZDh62N&$AYJ'::TEXT, 'arche.curt1990@hotmail.com'::EMAIL, 'United States'::TEXT);
SELECT createAccount('_Crsesnk2011'::TEXT, 'pmB$4CH&'::TEXT, 'damie.@outlook.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Damien'::TEXT, 'Cross'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('_tnd2013'::TEXT, 'O%1muACb4RvBYT'::TEXT, 'marcel.wel2013@outlook.com'::EMAIL, 'Canada'::TEXT);
SELECT createAccount('luc_Sinclai1992'::TEXT, 'y$6iDJy7h5#oFK1&84b'::TEXT, 'luci.sin410@yahoo.com'::EMAIL, 'Australia'::TEXT);
SELECT createAccount('zuzaJenni843'::TEXT, 'n&3wDFNr5zem%4h@'::TEXT, 'zuzan.j2013@gmail.com'::EMAIL, 'Canada'::TEXT, 'True'::BOOLEAN, 'Zuzanna'::TEXT, 'Jennings'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('sjri2009'::TEXT, 'o#4WCvo828'::TEXT, 's_townse2009@gmail.com'::EMAIL, 'Malta'::TEXT, 'False'::BOOLEAN, 'Sky'::TEXT, 'Townsend'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('magoul306'::TEXT, 'nO4u%LkZv6U'::TEXT, 'mari_go1987@hotmail.com'::EMAIL, 'United States'::TEXT);
SELECT createAccount('Kmrru2001'::TEXT, 'h%vSG7BF#j'::TEXT, 'tah_k2@hotmail.com'::EMAIL, 'Canada'::TEXT);
SELECT createAccount('Ange__Hutchi1977'::TEXT, 'r@DxJ2a#3GPi3pWz%3a'::TEXT, 'ange.5994@gmail.com'::EMAIL, 'United States'::TEXT);
SELECT createAccount('ashlePoo2009'::TEXT, 'l4I#oPtPRh3N@8spb'::TEXT, 'ashle_po_o5231@gmail.com'::EMAIL, 'New Zealand'::TEXT, 'True'::BOOLEAN, 'Ashley'::TEXT, 'Poole'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('viktoWoodwa1'::TEXT, 'bpI!T5qJi'::TEXT, 'viktori.woo_dwar2015@gmail.com'::EMAIL, 'Australia'::TEXT, 'False'::BOOLEAN, 'Viktoria'::TEXT, 'Woodward'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('juli_Ma2014'::TEXT, 'zK!g4D#9ZB2A7@0&R'::TEXT, 'j.@hotmail.com'::EMAIL, 'United Kingdom'::TEXT);
SELECT createAccount('kThorn58817'::TEXT, 'vuVP%9k&dp%@Y'::TEXT, 'k.thorn2013@outlook.com'::EMAIL, 'Ireland'::TEXT, 'True'::BOOLEAN, 'Koa'::TEXT, 'Thornton'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Sele_Sin08574'::TEXT, 'v3a#PF&#D2fE4O'::TEXT, 'selen.sing2007@outlook.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Selena'::TEXT, 'Singh'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('rtd1975'::TEXT, 'tP$N2dp&g6UThXldC%'::TEXT, 'fion._na107@outlook.com'::EMAIL, 'United Kingdom'::TEXT, 'False'::BOOLEAN, 'Fionn'::TEXT, 'Nash'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('E_gber17'::TEXT, 'uw!3CK@G#@mc5O'::TEXT, 'ev.1985@yahoo.com'::EMAIL, 'United Kingdom'::TEXT);
SELECT createAccount('_thorfu2002'::TEXT, 'f&e9DG182q@c6'::TEXT, 'oliwit49@yahoo.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Oliwia'::TEXT, 'Thornton'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Mar_sinc2005'::TEXT, 'p#dC7Nb5B%&gy@y13'::TEXT, 'mar.s2005@yahoo.com'::EMAIL, 'Guyana'::TEXT, 'True'::BOOLEAN, 'Mark'::TEXT, 'Sinclair'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('kayrxa9'::TEXT, 'c1#GYy$x&'::TEXT, 'kad.17@hotmail.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Kady'::TEXT, 'Lees'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Rayaa1'::TEXT, 'e#sS8YA5Spk&M#ckE#l'::TEXT, 'rayaa1996@gmail.com'::EMAIL, 'Ireland'::TEXT, 'False'::BOOLEAN, 'Rayaan'::TEXT, 'Gregory'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Mar_exhu1984'::TEXT, 'TRx4#rsG3%'::TEXT, 'marg.h1984@yahoo.com'::EMAIL, 'Canada'::TEXT, 'True'::BOOLEAN, 'Margo'::TEXT, 'Hill'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Alaybe'::TEXT, 'f!UC8w!4y@$!GC3Qzd9D'::TEXT, 'a.b88954@gmail.com'::EMAIL, 'Australia'::TEXT, 'False'::BOOLEAN, 'Alaya'::TEXT, 'Berry'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Ai_Gl_ove43472'::TEXT, 'r&c0BMt2q3fu50oBD2J&'::TEXT, 'aish_glo1493@gmail.com'::EMAIL, 'United States'::TEXT);
SELECT createAccount('tiannmcc1989'::TEXT, 'p3$KrED@g3x1v'::TEXT, 't_mccan1989@gmail.com'::EMAIL, 'United Kingdom'::TEXT, 'True'::BOOLEAN, 'Tianna'::TEXT, 'Mccann'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Ax__ba_ldw963'::TEXT, 'NvK2n@F72oKmz5m'::TEXT, 'ax_b1979@gmail.com'::EMAIL, 'United States'::TEXT);
SELECT createAccount('TMille2007'::TEXT, 'xw$S0Aa2E5C8S!2N0'::TEXT, 'to_mill@gmail.com'::EMAIL, 'United Kingdom'::TEXT, 'True'::BOOLEAN, 'Tom'::TEXT, 'Miller'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('jamacla_rk2019'::TEXT, 'tv5#FMly1zSHY#28'::TEXT, 'jama_2019@outlook.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Jamal'::TEXT, 'Clarke'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('rog_hi788'::TEXT, 'Bk3@kH27%!YLmBr@0dd7'::TEXT, 'rh2010@hotmail.com'::EMAIL, 'United Kingdom'::TEXT);
SELECT createAccount('SaHart_l1991'::TEXT, 'mSCl$7cAgM&Z@!9'::TEXT, 's_h005@outlook.com'::EMAIL, 'United States'::TEXT);
SELECT createAccount('_k_enxwaca1976'::TEXT, 'MEs!7nrX#I8APT'::TEXT, 'jk1976@gmail.com'::EMAIL, 'United States'::TEXT);
SELECT createAccount('eval_rodg1986'::TEXT, 'a3fHT#$GU39WW%T'::TEXT, 'evaly.1986@outlook.com'::EMAIL, 'Dominica'::TEXT, 'False'::BOOLEAN, 'Evalyn'::TEXT, 'Rodgers'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Luc_Snecd71'::TEXT, 'i!5rTH&&2!J@kKDqN%6'::TEXT, 'luc.suther2000@outlook.com'::EMAIL, 'Canada'::TEXT);
SELECT createAccount('SerArmst2009'::TEXT, 'JyDe@8IHS5Ya'::TEXT, 'sere_armstro6787@yahoo.com'::EMAIL, 'Malta'::TEXT, 'True'::BOOLEAN, 'Seren'::TEXT, 'Armstrong'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('norpdl2007'::TEXT, 'g#nX7T@HfGK'::TEXT, 'norad2007@hotmail.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Norah'::TEXT, 'Dunn'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('ere_Bryan2015'::TEXT, 'f6wJV@m8&V@rcc1'::TEXT, 'ere__b2015@gmail.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Eren'::TEXT, 'Bryant'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Ne_xdvig2017'::TEXT, 'fyV0!ZeH@Z$6P&Eq##'::TEXT, 'n.steel2017@hotmail.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Neve'::TEXT, 'Steele'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('honbr1990'::TEXT, 'xP$Fv4Kc$6u$Lm9510'::TEXT, 'hbr1990@outlook.com'::EMAIL, 'Australia'::TEXT, 'False'::BOOLEAN, 'Honor'::TEXT, 'Brown'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Mkrvt2021'::TEXT, 'a!4BGg50!4@&U1A!2dw'::TEXT, 'md_oug2021@yahoo.com'::EMAIL, 'Jamaica'::TEXT, 'False'::BOOLEAN, 'Mya'::TEXT, 'Douglas'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('HaO_ne0'::TEXT, 'aMx1%Z7L&@E'::TEXT, 'h_1991@gmail.com'::EMAIL, 'Ireland'::TEXT);
SELECT createAccount('Lauri54289'::TEXT, 'A9Uxg#8DP'::TEXT, 'laurib1993@gmail.com'::EMAIL, 'Canada'::TEXT, 'True'::BOOLEAN, 'Laurie'::TEXT, 'Burnett'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Fin_ndrjg2009'::TEXT, 'DkHk@3Pp#CDWXHKp'::TEXT, 'finla.2009@outlook.com'::EMAIL, 'Ireland'::TEXT, 'True'::BOOLEAN, 'Finlay'::TEXT, 'Kemp'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Jar_Ha1713'::TEXT, 'NwX5#ob2P12qt31D4!4!'::TEXT, 'jare.h_ar1997@gmail.com'::EMAIL, 'Canada'::TEXT, 'False'::BOOLEAN, 'Jared'::TEXT, 'Hartley'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('kari_Ba7'::TEXT, 'O2Oi%v%3ms64'::TEXT, 'karin_b_ak289@gmail.com'::EMAIL, 'United States'::TEXT);
SELECT createAccount('elsie_tu36134'::TEXT, 'g3%QKr!hY'::TEXT, 'elsie.tur1992@gmail.com'::EMAIL, 'United Kingdom'::TEXT, 'True'::BOOLEAN, 'Elsie-May'::TEXT, 'Turner'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('lil__bib98'::TEXT, 'oqI!A8XH4l9$y214'::TEXT, 'lill_bi1993@yahoo.com'::EMAIL, 'United Kingdom'::TEXT, 'True'::BOOLEAN, 'Lillie'::TEXT, 'Bibi'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('hel_ohee57009'::TEXT, 'q!0CbS&s&F'::TEXT, 'hele_os_b_or58@hotmail.com'::EMAIL, 'Jamaica'::TEXT, 'True'::BOOLEAN, 'Helen'::TEXT, 'Osborne'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('_Waltujavk'::TEXT, 'Ge$4UfxkM@$j'::TEXT, 'mwa84678@gmail.com'::EMAIL, 'Barbados'::TEXT, 'True'::BOOLEAN, 'Mikaeel'::TEXT, 'Walters'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Doria_n_ich1987'::TEXT, 'i#3ZWk$LA'::TEXT, 'doriani_chol1987@gmail.com'::EMAIL, 'United Kingdom'::TEXT);
SELECT createAccount('aleHarr_i85'::TEXT, 'o@JW0pD!1advp4pk4J'::TEXT, 'aleez.h@gmail.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Aleeza'::TEXT, 'Harrison'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('_rxin2022'::TEXT, 'jZ%6HqHm'::TEXT, 'brun2022@gmail.com'::EMAIL, 'United Kingdom'::TEXT, 'False'::BOOLEAN, 'Bruno'::TEXT, 'Ross'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('IsmaeH_ar2001'::TEXT, 'eiP7!Bwi'::TEXT, 'ismae.ha2001@yahoo.com'::EMAIL, 'New Zealand'::TEXT);
SELECT createAccount('Dawso_P_alm012'::TEXT, 'a2v&QT$@#HF1U0T'::TEXT, 'daws_pal2022@hotmail.com'::EMAIL, 'United Kingdom'::TEXT, 'True'::BOOLEAN, 'Dawson'::TEXT, 'Palmer'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('muru1988'::TEXT, 'h4IUr%3r%za$Wk45'::TEXT, 'annalis_n@outlook.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Annalise'::TEXT, 'Nelson'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('tyl_gelkmn2009'::TEXT, 'q1IIb$e#q43&8dS@z!'::TEXT, 'tyle.gou_l3641@yahoo.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Tyler'::TEXT, 'Gould'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('_reetcxax2002'::TEXT, 'f$8pIJNP409h@m0!'::TEXT, 'ray_2002@outlook.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Raya'::TEXT, 'Reed'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('ana_dou1985'::TEXT, 'x7!cGW5&g!OE%@A20Ugi'::TEXT, 'a.doug1985@gmail.com'::EMAIL, 'United States'::TEXT);
SELECT createAccount('junion_a5'::TEXT, 'n2T%Wwu$nSQ7'::TEXT, 'junin71004@gmail.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Junior'::TEXT, 'Nash'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Isla_Grh41'::TEXT, 'v#BI6sxqb'::TEXT, 'isla-g_how1998@hotmail.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Isla-Grace'::TEXT, 'Howarth'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('dNoraxbla0'::TEXT, 'Ua$2kR@O'::TEXT, 'de.n2016@hotmail.com'::EMAIL, 'United States'::TEXT);
SELECT createAccount('Lev_dar7491'::TEXT, 'h9eQL!TovpV4u&e1!B!'::TEXT, 'lev.s_h2008@outlook.com'::EMAIL, 'Canada'::TEXT, 'False'::BOOLEAN, 'Levi'::TEXT, 'Shah'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('ElisTuc049'::TEXT, 'x$o8XG$l3acBjdA@1QP'::TEXT, 'elish_tuck43483@outlook.com'::EMAIL, 'United States'::TEXT);
SELECT createAccount('isobel_mor72'::TEXT, 'JT4o&q7RBp'::TEXT, 'isobell.m2012@gmail.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Isobelle'::TEXT, 'Morton'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Co_mac2018'::TEXT, 'fA@q5H$D!8R5'::TEXT, 'coha.mackenz65@yahoo.com'::EMAIL, 'United Kingdom'::TEXT, 'False'::BOOLEAN, 'Cohan'::TEXT, 'Mackenzie'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Leonar53'::TEXT, 'U3Eoj&$@5aYPQUZ'::TEXT, 'leonar.r61961@gmail.com'::EMAIL, 'United States'::TEXT);
SELECT createAccount('Sco_vvc2014'::TEXT, 'EJ5i%ed!1mf!2V!se4'::TEXT, 'scot.shor2014@gmail.com'::EMAIL, 'Australia'::TEXT, 'True'::BOOLEAN, 'Scott'::TEXT, 'Short'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('astoBar_be'::TEXT, 'J!vU2v!@5hER4s6e9t0'::TEXT, 'a6@gmail.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Aston'::TEXT, 'Barber'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('kar_R_eev65'::TEXT, 'jCl3X&Q2W41Fat!zWk@2'::TEXT, 'karee.re@outlook.com'::EMAIL, 'Canada'::TEXT, 'True'::BOOLEAN, 'Kareem'::TEXT, 'Reeves'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('te_Wectxb2017'::TEXT, 'ZeZ7x@46#8Q!5Y!&tNGD'::TEXT, 'tesw246@hotmail.com'::EMAIL, 'Australia'::TEXT, 'True'::BOOLEAN, 'Tess'::TEXT, 'Webb'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('hon_wcpr4766'::TEXT, 'k6G!sL#%k#%1'::TEXT, 'h.wilso2020@hotmail.com'::EMAIL, 'Canada'::TEXT, 'True'::BOOLEAN, 'Honey'::TEXT, 'Wilson'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('lia_Patterso63294'::TEXT, 'tTjL%6LNv@N#'::TEXT, 'lia_p_atter12@gmail.com'::EMAIL, 'Canada'::TEXT, 'True'::BOOLEAN, 'Liam'::TEXT, 'Patterson'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('KubBa1999'::TEXT, 'lsPK8%485&We&'::TEXT, 'kubbak3@gmail.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Kuba'::TEXT, 'Baker'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('arabelgr_aha'::TEXT, 'oj2PZ$52RU!A4n%sGTn'::TEXT, 'arabel.g3048@yahoo.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Arabella'::TEXT, 'Graham'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Paqemm20'::TEXT, 'l@RrX1C@'::TEXT, 'p.town1996@gmail.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Paris'::TEXT, 'Townsend'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Sav_mcdonal2005'::TEXT, 'wi2&DJ1I!8dWT$U#u9%M'::TEXT, 'sava.mcdonal927@gmail.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Savannah'::TEXT, 'Mcdonald'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Owarile2010'::TEXT, 'Yk0Gp@N58%w$'::TEXT, 'owai.ri@gmail.com'::EMAIL, 'United States'::TEXT);
SELECT createAccount('Albflemin1992'::TEXT, 'b1DzF#x!Haj'::TEXT, 'alb.fle1992@hotmail.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Alba'::TEXT, 'Fleming'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('luel_sh_epher1999'::TEXT, 'j1D@Hw5c44Np3LYLv336'::TEXT, 'luell_s20527@hotmail.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Luella'::TEXT, 'Shepherd'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('tal__Sh2005'::TEXT, 'qc$2BSwq'::TEXT, 'tali_sh2005@gmail.com'::EMAIL, 'New Zealand'::TEXT);
SELECT createAccount('lextn'::TEXT, 'q3!IWn42'::TEXT, 'leo_cunnin3@gmail.com'::EMAIL, 'United Kingdom'::TEXT, 'False'::BOOLEAN, 'Leon'::TEXT, 'Cunningham'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('ayhbwsf1999'::TEXT, 'dB2F$vQN'::TEXT, 'ayma._bi298@gmail.com'::EMAIL, 'Canada'::TEXT, 'False'::BOOLEAN, 'Ayman'::TEXT, 'Bird'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('slatave347'::TEXT, 'l4tOL$B5zD'::TEXT, 'georg.sla1969@outlook.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Georgi'::TEXT, 'Slater'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('lewikmrs63'::TEXT, 'wv7K@T#1IROaY'::TEXT, 'lewicla5616@hotmail.com'::EMAIL, 'United Kingdom'::TEXT);
SELECT createAccount('SafiRo73648'::TEXT, 'Fr5Nz$J35%$'::TEXT, 's.@gmail.com'::EMAIL, 'New Zealand'::TEXT, 'False'::BOOLEAN, 'Safia'::TEXT, 'Rodgers'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('adnjoyc2003'::TEXT, 'A6gTn@d1TG8814&HeOL'::TEXT, 'adna_jo2003@gmail.com'::EMAIL, 'United Kingdom'::TEXT, 'True'::BOOLEAN, 'Adnan'::TEXT, 'Joyce'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('carpsncpp670'::TEXT, 'J!2tmYHE'::TEXT, 'lexcarpe6475@gmail.com'::EMAIL, 'United Kingdom'::TEXT);
SELECT createAccount('elspet16'::TEXT, 'd#4RdDG@ylrBq3MP%o'::TEXT, 'elspet.gilbe1992@gmail.com'::EMAIL, 'Ireland'::TEXT, 'False'::BOOLEAN, 'Elspeth'::TEXT, 'Gilbert'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Mali_N_o50539'::TEXT, 'xLVr9&XFU41fS4r'::TEXT, 'mali.n1990@yahoo.com'::EMAIL, 'Canada'::TEXT);
SELECT createAccount('TiaSwwu2011'::TEXT, 'FYs5#hX%'::TEXT, 'tiag.s2011@yahoo.com'::EMAIL, 'United Kingdom'::TEXT, 'False'::BOOLEAN, 'Tiago'::TEXT, 'Smart'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Annabe_jo1991'::TEXT, 'y3&TpA4r78656MNH3&G%'::TEXT, 'annabe_joh1991@hotmail.com'::EMAIL, 'Bahamas'::TEXT);
SELECT createAccount('Dalt_ne2016'::TEXT, 'e!C5uZ!bdgiU'::TEXT, 'dalto.nelso364@gmail.com'::EMAIL, 'Ireland'::TEXT, 'False'::BOOLEAN, 'Dalton'::TEXT, 'Nelson'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('win_free2014'::TEXT, 'c!zEF76%k5&&gtxg!'::TEXT, 'winifrfreem2014@gmail.com'::EMAIL, 'United Kingdom'::TEXT);
SELECT createAccount('Israearno2012'::TEXT, 'l%YH2qw!&s'::TEXT, 'israe.arnol68@gmail.com'::EMAIL, 'Ireland'::TEXT);
SELECT createAccount('cono_h1970'::TEXT, 'o!QhE3PzoU%'::TEXT, 'cono.h1970@hotmail.com'::EMAIL, 'Ireland'::TEXT);
SELECT createAccount('krzysztS_heph'::TEXT, 'lhT6#Q30&m3X&I3'::TEXT, 'krzy.shepher2003@gmail.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Krzysztof'::TEXT, 'Shepherd'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('kiyHay2003'::TEXT, 'v1@dKPZ8MP%'::TEXT, 'kiya_18@outlook.com'::EMAIL, 'United Kingdom'::TEXT, 'False'::BOOLEAN, 'Kiyan'::TEXT, 'Hayes'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('chas_Camer1979'::TEXT, 'r#7FiKK2E2@@7I$6gLeF'::TEXT, 'chascam_e1979@outlook.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Chase'::TEXT, 'Cameron'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('BetM_urph2856'::TEXT, 'lq2$CHY31l&w9qDt'::TEXT, 'betsm9@outlook.com'::EMAIL, 'Canada'::TEXT, 'False'::BOOLEAN, 'Betsy'::TEXT, 'Murphy'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Ishbmqhsh52'::TEXT, 'i%H2Pf!&1$F'::TEXT, 'ishba55@outlook.com'::EMAIL, 'United States'::TEXT);
SELECT createAccount('evangeli1989'::TEXT, 'e@x1KWvl8KOwwQH'::TEXT, 'evan.har1989@outlook.com'::EMAIL, 'Barbados'::TEXT, 'False'::BOOLEAN, 'Evangeline'::TEXT, 'Harvey'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('arhMac30610'::TEXT, 'gX&7Vw@65f&'::TEXT, 'a.mac_kenz98@gmail.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Arham'::TEXT, 'Mackenzie'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('yusr_F2010'::TEXT, 'q$3BQp744J#v4d8@QnR'::TEXT, 'yusrflet_c78500@outlook.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Yusra'::TEXT, 'Fletcher'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('zacsm7688'::TEXT, 'H&ij3SNFS!&'::TEXT, 'zac.s97@hotmail.com'::EMAIL, 'Malta'::TEXT, 'False'::BOOLEAN, 'Zach'::TEXT, 'Smyth'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Kenn_Hardin39'::TEXT, 'cf%8NM&y#dZ3'::TEXT, 'k_hard@outlook.com'::EMAIL, 'United Kingdom'::TEXT);
SELECT createAccount('pugjoxyp2013'::TEXT, 'urX@A4@WX%K!'::TEXT, 'juliett.078@gmail.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Juliette'::TEXT, 'Pugh'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('katev34416'::TEXT, 'NX#5ydM001jf'::TEXT, 'k__ros87879@yahoo.com'::EMAIL, 'Canada'::TEXT, 'True'::BOOLEAN, 'Kai'::TEXT, 'Ross'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('efBruc62640'::TEXT, 't4aFL!YqY@mWUM1088N'::TEXT, 'e.892@gmail.com'::EMAIL, 'United States'::TEXT);
SELECT createAccount('Uma_bat2022'::TEXT, 'k!eIY347$EVF&2!3JN3'::TEXT, 'u.b10160@hotmail.com'::EMAIL, 'Canada'::TEXT, 'True'::BOOLEAN, 'Umar'::TEXT, 'Bates'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('betha'::TEXT, 'fgH#1Aj%'::TEXT, 'b.s_t47@gmail.com'::EMAIL, 'Belize'::TEXT);
SELECT createAccount('Clkaobqz9'::TEXT, 'n9y%OPgS$@w'::TEXT, 'clar.ka32625@gmail.com'::EMAIL, 'United Kingdom'::TEXT, 'False'::BOOLEAN, 'Clara'::TEXT, 'Kay'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('__Willia1995'::TEXT, 'ffZ4#B%QNGlTE9X1'::TEXT, 'lily-rw_ill1995@outlook.com'::EMAIL, 'United Kingdom'::TEXT);
SELECT createAccount('Aay_Lwuf7049'::TEXT, 'I%0PmilcO7tZ14@X'::TEXT, 'aaya_1991@gmail.com'::EMAIL, 'United States'::TEXT);
SELECT createAccount('Mar_wdc2020'::TEXT, 'oc8YV&!1q!7q!%1O7'::TEXT, 'margo_l2020@hotmail.com'::EMAIL, 'United States'::TEXT);
SELECT createAccount('MelodDoher3882'::TEXT, 't!5HhV&U6rgnX&8Kn'::TEXT, 'melod__dohe1993@gmail.com'::EMAIL, 'Australia'::TEXT, 'True'::BOOLEAN, 'Melody'::TEXT, 'Doherty'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('zoe_for2000'::TEXT, 'o1j@JUj4E5Gv4'::TEXT, 'zoe_@gmail.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Zoey'::TEXT, 'Forbes'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Amn_rfhq12'::TEXT, 'xDOg2!#E1Vi!'::TEXT, 'amnke2003@gmail.com'::EMAIL, 'Canada'::TEXT, 'True'::BOOLEAN, 'Amna'::TEXT, 'Kerr'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('DorotDicks28330'::TEXT, 'c%0RgXZ4$9'::TEXT, 'doro_dic_k1971@gmail.com'::EMAIL, 'United Kingdom'::TEXT);
SELECT createAccount('MylThomp1990'::TEXT, 'mg@5TIXa@P@15Q0uATBf'::TEXT, 'myl.t21482@gmail.com'::EMAIL, 'United States'::TEXT);
SELECT createAccount('kaj_wal2012'::TEXT, 'KR$5fhhv!k&@CWW&3b'::TEXT, 'kaju_984@hotmail.com'::EMAIL, 'Canada'::TEXT, 'False'::BOOLEAN, 'Kajus'::TEXT, 'Walsh'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Fatim_Ell1041'::TEXT, 'E&pB5k5tH%XYt7!nNgw'::TEXT, 'fatim.el2022@gmail.com'::EMAIL, 'Australia'::TEXT, 'True'::BOOLEAN, 'Fatima'::TEXT, 'Ellis'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('alesaust2002'::TEXT, 'I5Ooz@x&t$5&Ppky5@BS'::TEXT, 'alessandaus2002@gmail.com'::EMAIL, 'United Kingdom'::TEXT);
SELECT createAccount('geor_ucycy2008'::TEXT, 'h#dJ5E0!@#l&k##Vn#H&'::TEXT, 'georgiboy2008@outlook.com'::EMAIL, 'United States'::TEXT);
SELECT createAccount('HerbNicho_l2013'::TEXT, 'wUGl9%Y$8AS@@2!@@G#4'::TEXT, 'herber2013@gmail.com'::EMAIL, 'United Kingdom'::TEXT, 'True'::BOOLEAN, 'Herbert'::TEXT, 'Nicholls'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('dan_chandl7'::TEXT, 's6hU%Xi7R51mYa2'::TEXT, 'danya.c001@hotmail.com'::EMAIL, 'Canada'::TEXT, 'False'::BOOLEAN, 'Danyal'::TEXT, 'Chandler'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('HeidHar2005'::TEXT, 'wB3hP$3y40t5TcP@J'::TEXT, 'heid.h2005@gmail.com'::EMAIL, 'United States'::TEXT);
SELECT createAccount('Madsch1998'::TEXT, 'ZHd5@yn3IGcVxR4@V'::TEXT, 'maddo.@outlook.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Maddox'::TEXT, 'Fox'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Meli_burk50908'::TEXT, 'c4#AhQhkP@j@#'::TEXT, 'meliss.b2000@outlook.com'::EMAIL, 'United Kingdom'::TEXT, 'True'::BOOLEAN, 'Melissa'::TEXT, 'Burke'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('cam_Wlfwt2012'::TEXT, 'R%xQr2n@&22#hsr@#!0$'::TEXT, 'camero.wa7@hotmail.com'::EMAIL, 'Jamaica'::TEXT);
SELECT createAccount('annste2002'::TEXT, 'k3GGn@f4F%'::TEXT, 'annabell_st_e2002@hotmail.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Annabelle'::TEXT, 'Stephenson'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('_ricvhyk009'::TEXT, 'eIyS@165VB'::TEXT, 'islar.r_ic2005@gmail.com'::EMAIL, 'Australia'::TEXT, 'False'::BOOLEAN, 'Isla-Rae'::TEXT, 'Rice'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('AurorMckenn1976'::TEXT, 'n@u8EL$33'::TEXT, 'a.1976@gmail.com'::EMAIL, 'Ireland'::TEXT, 'False'::BOOLEAN, 'Aurora'::TEXT, 'Mckenna'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('_Cgqwq1987'::TEXT, 'ps@EI76$DqP!M%@sO'::TEXT, 'wcol6@yahoo.com'::EMAIL, 'United Kingdom'::TEXT, 'False'::BOOLEAN, 'Wilbur'::TEXT, 'Cole'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Reb_wo17'::TEXT, 'J@zE2a9A9I0$A4j'::TEXT, 'rebeka.2008@hotmail.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Rebekah'::TEXT, 'Wood'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Kyr_Ba1999'::TEXT, 'cg1$CD44&$kB#57#M5Z'::TEXT, 'kyra.35@outlook.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Kyran'::TEXT, 'Ball'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('ShaPater6757'::TEXT, 'uc5N%W54r!%2@'::TEXT, 'shap21757@gmail.com'::EMAIL, 'Canada'::TEXT);
SELECT createAccount('Hentoj1999'::TEXT, 'k!O4uWE&5'::TEXT, 'kyro1999@gmail.com'::EMAIL, 'Australia'::TEXT, 'True'::BOOLEAN, 'Kyron'::TEXT, 'Henry'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('elinPalm966'::TEXT, 'YIg8v!#Yrupu'::TEXT, 'epa2318@outlook.com'::EMAIL, 'Australia'::TEXT);
SELECT createAccount('pal__Bcanfh2010'::TEXT, 'j0k!XH1A5lCsj3&!fgO'::TEXT, 'palomba_il2010@gmail.com'::EMAIL, 'Ireland'::TEXT, 'False'::BOOLEAN, 'Paloma'::TEXT, 'Bailey'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Naom_Richa2009'::TEXT, 'J2Ec@g@#%C#A%C2'::TEXT, 'naom._richa946@outlook.com'::EMAIL, 'United States'::TEXT);
SELECT createAccount('seli_frase253'::TEXT, 'T8mC!pR@69x'::TEXT, 'selin.fra_s11611@outlook.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Selina'::TEXT, 'Fraser'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Maxa_Ch613'::TEXT, 'sJuQ$5$4'::TEXT, 'maxanc.cha_u_vea8@yahoo.com'::EMAIL, 'France'::TEXT);
SELECT createAccount('dg_oekxyw2019'::TEXT, 'qrWX0$gcI@855@4%y5'::TEXT, 'd_g@hotmail.com'::EMAIL, 'France'::TEXT, 'False'::BOOLEAN, 'Dan'::TEXT, 'Goetz'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('ser_cha1999'::TEXT, 'x&ZhK4$zg7f@gW7V'::TEXT, 'serg_1999@hotmail.com'::EMAIL, 'France'::TEXT, 'True'::BOOLEAN, 'Serge'::TEXT, 'Chauvin'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('eleonGu_il28'::TEXT, 'mdVT%2S!R2YpE$'::TEXT, 'eleonor_gu89@gmail.com'::EMAIL, 'France'::TEXT);
SELECT createAccount('Sol_So686'::TEXT, 'E%n5qJ%fVt$I2%'::TEXT, 'sola.soular94206@gmail.com'::EMAIL, 'France'::TEXT, 'True'::BOOLEAN, 'Solan'::TEXT, 'Soulard'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Rachego2010'::TEXT, 'wR5!cU!8!q0J923#sW'::TEXT, 'rache__gob@yahoo.com'::EMAIL, 'France'::TEXT);
SELECT createAccount('Matil_no_e2019'::TEXT, 'p@VBt14gU2%#gir4&!q'::TEXT, 'matild_noe69@gmail.com'::EMAIL, 'France'::TEXT, 'True'::BOOLEAN, 'Matilde'::TEXT, 'Noel'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('yjb2006'::TEXT, 'hZdF2$fenvp'::TEXT, 'k.carl72632@gmail.com'::EMAIL, 'France'::TEXT, 'True'::BOOLEAN, 'Kellian'::TEXT, 'Carle'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Merihul5670'::TEXT, 'KB&5ut4O2'::TEXT, 'merie_ro@hotmail.com'::EMAIL, 'France'::TEXT, 'True'::BOOLEAN, 'Meriem'::TEXT, 'Rouxel'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('lduq1994'::TEXT, 'dX$7Nln!d@W@Q#NQ'::TEXT, 'flora.lat3@yahoo.com'::EMAIL, 'France'::TEXT, 'True'::BOOLEAN, 'Floran'::TEXT, 'Latour'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('JuliaHart1996'::TEXT, 'Emh&F9N8HJ6!p'::TEXT, 'julia.h781@hotmail.com'::EMAIL, 'French Guiana'::TEXT, 'True'::BOOLEAN, 'Julian'::TEXT, 'Hartmann'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('manoeayl2007'::TEXT, 'yx%A1CbLth@Mz7%'::TEXT, 'manomau_r@gmail.com'::EMAIL, 'French Guiana'::TEXT, 'True'::BOOLEAN, 'Manoé'::TEXT, 'Maurer'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('jen_devi28'::TEXT, 'dj3@YG3s@'::TEXT, 'jenn.@yahoo.com'::EMAIL, 'France'::TEXT, 'True'::BOOLEAN, 'Jenny'::TEXT, 'Deville'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Juanslzc4'::TEXT, 'cvU7L@!m4nM8i'::TEXT, 'juanit_d2006@gmail.com'::EMAIL, 'French Guiana'::TEXT, 'False'::BOOLEAN, 'Juanito'::TEXT, 'Dulac'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('buo6'::TEXT, 'vKFa%13jr7'::TEXT, 'ginet66264@outlook.com'::EMAIL, 'France'::TEXT, 'False'::BOOLEAN, 'Ginette'::TEXT, 'Bouche'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Cleme_J4556'::TEXT, 'eJn1V!r2#'::TEXT, 'c_jo84@gmail.com'::EMAIL, 'France'::TEXT, 'False'::BOOLEAN, 'Clemence'::TEXT, 'Jolly'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Az_mfwh2005'::TEXT, 'l%w8RQ$5Z8$Ko'::TEXT, 'aza.64@hotmail.com'::EMAIL, 'France'::TEXT, 'True'::BOOLEAN, 'Azad'::TEXT, 'Briot'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('KenAnn2009'::TEXT, 'n$2TfX&E!31We'::TEXT, 'kena.2009@gmail.com'::EMAIL, 'France'::TEXT, 'False'::BOOLEAN, 'Kenan'::TEXT, 'Anne'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('MathilAnc1979'::TEXT, 'uEY1s&JabxjF&@GzI'::TEXT, 'mathild.a679@gmail.com'::EMAIL, 'France'::TEXT, 'True'::BOOLEAN, 'Mathilde'::TEXT, 'Ancel'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('shirB1980'::TEXT, 'Pa@f0L43E!x@p%9'::TEXT, 'shirle._beno1980@hotmail.com'::EMAIL, 'France'::TEXT, 'True'::BOOLEAN, 'Shirley'::TEXT, 'Benoist'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('jont_wil1998'::TEXT, 'o5p&AN&4di3m2x%x8@'::TEXT, 'jont._wilk_e7@hotmail.com'::EMAIL, 'Denmark'::TEXT, 'True'::BOOLEAN, 'Jonte'::TEXT, 'Wilkens'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Ju_rus78606'::TEXT, 'KGx1@c4%Ls1&0p%#3J$'::TEXT, 'juli_ru1991@outlook.com'::EMAIL, 'Austria'::TEXT, 'False'::BOOLEAN, 'Julie'::TEXT, 'Rust'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Marl_pxww2012'::TEXT, 'I5P&yh90cp3'::TEXT, 'marlee_janz2012@yahoo.com'::EMAIL, 'Switzerland'::TEXT);
SELECT createAccount('luHan2014'::TEXT, 'g2m$BSP@3&#L%0!5ye'::TEXT, 'lutha2014@gmail.com'::EMAIL, 'Germany'::TEXT, 'True'::BOOLEAN, 'Lutz'::TEXT, 'Hänel'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('ibrTes827'::TEXT, 'DY3$ypc@d'::TEXT, 'ibrahi.tesc2003@gmail.com'::EMAIL, 'Denmark'::TEXT, 'False'::BOOLEAN, 'Ibrahim'::TEXT, 'Tesch'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Maxi_e71952'::TEXT, 'k#NY9j&Cl#$6%G'::TEXT, 'maximili.ede20@outlook.com'::EMAIL, 'Germany'::TEXT);
SELECT createAccount('melik_Bor_o'::TEXT, 'pS!u9Bs$S4Xq!SK8S%5'::TEXT, 'melik_borowsk128@outlook.com'::EMAIL, 'Denmark'::TEXT, 'False'::BOOLEAN, 'Melike'::TEXT, 'Borowski'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Ronjhildebrand1999'::TEXT, 'z%1wLPcSUcv0VSMTm'::TEXT, 'ronjhilde_b_ra1999@gmail.com'::EMAIL, 'Germany'::TEXT, 'False'::BOOLEAN, 'Ronja'::TEXT, 'Hildebrandt'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Mart_ba19318'::TEXT, 'nb0V%Jd926&'::TEXT, 'marth.backe2013@yahoo.com'::EMAIL, 'Denmark'::TEXT, 'False'::BOOLEAN, 'Martha'::TEXT, 'Backes'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('gesb2011'::TEXT, 'Pg3pN%U&xfM!@'::TEXT, 'giul.2011@outlook.com'::EMAIL, 'Denmark'::TEXT, 'True'::BOOLEAN, 'Giulia'::TEXT, 'Götze'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('_w_olfswcfe1990'::TEXT, 'j@eXQ9$xu&4vb#!%!g0r'::TEXT, 'jon.wo1990@hotmail.com'::EMAIL, 'Austria'::TEXT, 'False'::BOOLEAN, 'Jona'::TEXT, 'Wolff'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('leon_djgew15'::TEXT, 'wm!6DCLI9C480u&vIx5'::TEXT, 'leoniknap2010@gmail.com'::EMAIL, 'Belgium'::TEXT, 'False'::BOOLEAN, 'Leonie'::TEXT, 'Knappe'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('hau_Dspqy29'::TEXT, 'Ibx5H#&u$@5t!S7L'::TEXT, 'hauk_di6@yahoo.com'::EMAIL, 'Germany'::TEXT, 'True'::BOOLEAN, 'Hauke'::TEXT, 'Dittmar'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Jordjak2015'::TEXT, 'o$5MnT3%7'::TEXT, 'jorda.jakob2015@hotmail.com'::EMAIL, 'Netherlands'::TEXT);
SELECT createAccount('Johann_'::TEXT, 'bm@CZ5aQh2'::TEXT, 'j.wal01@outlook.com'::EMAIL, 'Netherlands'::TEXT);
SELECT createAccount('jon_M_e53'::TEXT, 'jQEb!9548ZyL'::TEXT, 'jon.me_i_n51054@outlook.com'::EMAIL, 'Denmark'::TEXT, 'False'::BOOLEAN, 'Jona'::TEXT, 'Meiners'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('jasm_wes2019'::TEXT, 'H!p6kM3o@WX%F%3B'::TEXT, 'jasmi_2019@yahoo.com'::EMAIL, 'Netherlands'::TEXT, 'False'::BOOLEAN, 'Jasmina'::TEXT, 'Westphal'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('jardre'::TEXT, 'eD!j5DHp'::TEXT, 'j_dr91@outlook.com'::EMAIL, 'Germany'::TEXT);
SELECT createAccount('_Rathm6550'::TEXT, 'a5%RMtjgKojx#O4m@u3f'::TEXT, 'f_rathman9520@yahoo.com'::EMAIL, 'Switzerland'::TEXT, 'False'::BOOLEAN, 'Fina'::TEXT, 'Rathmann'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Elen_L7525'::TEXT, 'D$6Ies$fTGY'::TEXT, 'elen.2002@yahoo.com'::EMAIL, 'Liechtenstein'::TEXT, 'False'::BOOLEAN, 'Elena'::TEXT, 'Löwe'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('DeviCon2010'::TEXT, 'xJ$Pl5v11lVj61bvy3'::TEXT, 'devi.c_o067@gmail.com'::EMAIL, 'Austria'::TEXT, 'False'::BOOLEAN, 'Devin'::TEXT, 'Conrad'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('AidHoh8'::TEXT, 'nv0@LOEP3XFyl&1$1#p3'::TEXT, 'aide.hohm2005@outlook.com'::EMAIL, 'Denmark'::TEXT);
SELECT createAccount('ckkv2006'::TEXT, 'x%9AEsmW@8F9&Vr5'::TEXT, 'lgru_n6634@gmail.com'::EMAIL, 'Netherlands'::TEXT);
SELECT createAccount('nathan_We559'::TEXT, 'e$eHI8o&'::TEXT, 'n_1996@outlook.com'::EMAIL, 'Germany'::TEXT);
SELECT createAccount('qui_ab2003'::TEXT, 'scAP&4FEP05%H'::TEXT, 'quiri_ab2003@gmail.com'::EMAIL, 'Netherlands'::TEXT);
SELECT createAccount('VioletSie1989'::TEXT, 'j0$RJb7c@W6N'::TEXT, 'violet.si_ev4379@gmail.com'::EMAIL, 'Germany'::TEXT);
SELECT createAccount('MarStolz1983'::TEXT, 'b8QZ&x12T&gF@@'::TEXT, 'mare@gmail.com'::EMAIL, 'Germany'::TEXT, 'True'::BOOLEAN, 'Marek'::TEXT, 'Stolze'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Etieh1982'::TEXT, 'rAUf%2ycHU0@%5P'::TEXT, 'etie.hen60@gmail.com'::EMAIL, 'Germany'::TEXT, 'True'::BOOLEAN, 'Etienne'::TEXT, 'Hennig'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('bianK2006'::TEXT, 't9ZKu$Q12YgxE&8N&'::TEXT, 'bianc_71819@outlook.com'::EMAIL, 'Denmark'::TEXT);
SELECT createAccount('kBexzsa02690'::TEXT, 'Z9T@hnVP!ivFN'::TEXT, 'kbe09@gmail.com'::EMAIL, 'Japan'::TEXT, 'False'::BOOLEAN, 'Kun'::TEXT, 'Ben'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Y_dhhd'::TEXT, 'p#KkH3F35KAX5'::TEXT, 'y.d2014@gmail.com'::EMAIL, 'China'::TEXT, 'True'::BOOLEAN, 'Yu'::TEXT, 'Dou'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('aigu_x2011'::TEXT, 'm@UQ5zP!F9Hl'::TEXT, 'aigu__x_u60@hotmail.com'::EMAIL, 'Japan'::TEXT, 'True'::BOOLEAN, 'Aiguo'::TEXT, 'Xue'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('_kcvz2015'::TEXT, 'V5Dfh!T7&un03yl6!KQ'::TEXT, 'y_ko2015@outlook.com'::EMAIL, 'Japan'::TEXT, 'False'::BOOLEAN, 'Yue'::TEXT, 'Kou'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('zhenhuGu1960'::TEXT, 'l3m@XIH&R%'::TEXT, 'zhenhu.1960@hotmail.com'::EMAIL, 'Taiwan'::TEXT, 'False'::BOOLEAN, 'Zhenhua'::TEXT, 'Guan'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Jooi7'::TEXT, 'i#r4KU7y5DV'::TEXT, 'guir_ji_n1978@yahoo.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Guirong'::TEXT, 'Jing'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Fengq_zo'::TEXT, 'aM!0tR8g%sBwp1Jr'::TEXT, 'fengqi.2001@gmail.com'::EMAIL, 'China'::TEXT, 'True'::BOOLEAN, 'Fengqin'::TEXT, 'Zou'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Jin_inp'::TEXT, 'c2RwD$$!R$83m@%!a'::TEXT, 'jin_1995@gmail.com'::EMAIL, 'China'::TEXT);
SELECT createAccount('PanTimmvw7'::TEXT, 'u0&wDQ%!$2oo9#&'::TEXT, 'panp.t2000@gmail.com'::EMAIL, 'China'::TEXT, 'True'::BOOLEAN, 'Panpan'::TEXT, 'Tan'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('wenggynb84728'::TEXT, 'n%4nOF7ab#hcft9Y'::TEXT, 'wenzu_gon2007@yahoo.com'::EMAIL, 'China'::TEXT);
SELECT createAccount('Ronjrxys7'::TEXT, 'd5@tOF!!48bj$w'::TEXT, 'r_2017@hotmail.com'::EMAIL, 'China'::TEXT);
SELECT createAccount('Rontalr1987'::TEXT, 's0UpT!51X'::TEXT, 'ronghu._t658@hotmail.com'::EMAIL, 'China'::TEXT, 'True'::BOOLEAN, 'Ronghua'::TEXT, 'Tie'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Liangqi21'::TEXT, 'mT4Sh!eLzt5@vc5'::TEXT, 'q_li2013@outlook.com'::EMAIL, 'China'::TEXT, 'True'::BOOLEAN, 'Qiang'::TEXT, 'Liangqiu'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('xueqZh2019'::TEXT, 'Q@9iXk0!c'::TEXT, 'xueqiz2019@outlook.com'::EMAIL, 'Taiwan'::TEXT, 'True'::BOOLEAN, 'Xueqin'::TEXT, 'Zhan'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('HonBe1995'::TEXT, 'twNW9&4&q2'::TEXT, 'hongju.b@gmail.com'::EMAIL, 'China'::TEXT, 'True'::BOOLEAN, 'Hongjun'::TEXT, 'Bei'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('gLgbmeg2020'::TEXT, 'vNvD7%V#&W@H9MEh3'::TEXT, 'gu_l1483@hotmail.com'::EMAIL, 'China'::TEXT, 'True'::BOOLEAN, 'Gui'::TEXT, 'Li'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('qiume_d2021'::TEXT, 'x&5hEILEfU2LFlm5Ce'::TEXT, 'qiumed395@gmail.com'::EMAIL, 'Japan'::TEXT, 'True'::BOOLEAN, 'Qiumei'::TEXT, 'Du'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('_fll2010'::TEXT, 'W4%lsLP##1!3$Ehg'::TEXT, 'g.xia2010@gmail.com'::EMAIL, 'Japan'::TEXT);
SELECT createAccount('Caiho_G2015'::TEXT, 'sEwG$0H$k8aJh!7%'::TEXT, 'caiho.84911@hotmail.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Caihong'::TEXT, 'Ge'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Xue_lcgxda18'::TEXT, 'uQ0!aA@Y'::TEXT, 'x.l2001@gmail.com'::EMAIL, 'China'::TEXT, 'True'::BOOLEAN, 'Xueqin'::TEXT, 'Lu'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Yon_hpayv552'::TEXT, 'q4LL!kdGb0GAxeID5'::TEXT, 'yong_4@hotmail.com'::EMAIL, 'China'::TEXT, 'True'::BOOLEAN, 'Yonghui'::TEXT, 'Gu'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('qiply939'::TEXT, 'e&1RBmNX'::TEXT, 'kqia01173@gmail.com'::EMAIL, 'China'::TEXT, 'True'::BOOLEAN, 'Ke'::TEXT, 'Qiao'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Jiafbnd'::TEXT, 'oM5@Gm33dL!%LM!#uw#u'::TEXT, 'jia.f1984@gmail.com'::EMAIL, 'China'::TEXT);
SELECT createAccount('huimi_ya1992'::TEXT, 'h@X1gP$v&1%!14dQ41$'::TEXT, 'huimi.1992@hotmail.com'::EMAIL, 'Taiwan'::TEXT, 'True'::BOOLEAN, 'Huimin'::TEXT, 'Yan'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('xiao_z_hangji2018'::TEXT, 'v%2mOM#15F'::TEXT, 'xiaomi.z_ha_ng9@gmail.com'::EMAIL, 'Japan'::TEXT, 'False'::BOOLEAN, 'Xiaomin'::TEXT, 'Zhangjia'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('dongme_Q44339'::TEXT, 'eyR$2DCn@@41$N@9'::TEXT, 'dongme.qua573@outlook.com'::EMAIL, 'China'::TEXT);
SELECT createAccount('feng__b70187'::TEXT, 'T@G9scU%w4WOVmntl@w!'::TEXT, 'feng__b90@gmail.com'::EMAIL, 'Taiwan'::TEXT);
SELECT createAccount('Weig_Ha1987'::TEXT, 'd4%xLIH%0X5StL!&@'::TEXT, 'weigu.h2935@gmail.com'::EMAIL, 'Japan'::TEXT);
SELECT createAccount('yonghp2015'::TEXT, 'nFwH1#5@83I2'::TEXT, 'yonghupen15677@yahoo.com'::EMAIL, 'Taiwan'::TEXT, 'False'::BOOLEAN, 'Yonghui'::TEXT, 'Peng'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Yaq_ysrv2002'::TEXT, 'd9#mUV3C!#JO&p5'::TEXT, 'yaqij2002@yahoo.com'::EMAIL, 'United States'::TEXT);
SELECT createAccount('Jigcwu'::TEXT, 'mYu#0S@1TzZx$x%%6'::TEXT, 'con2000@gmail.com'::EMAIL, 'Taiwan'::TEXT, 'True'::BOOLEAN, 'Cong'::TEXT, 'Jia'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('zunhgu4165'::TEXT, 'ss&3EE!%#vrZ'::TEXT, 'zunhu.8339@gmail.com'::EMAIL, 'China'::TEXT, 'True'::BOOLEAN, 'Zunhua'::TEXT, 'Guan'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('toCienc11205'::TEXT, 'Xjy%9Tg6LL'::TEXT, 't_ch64724@outlook.com'::EMAIL, 'China'::TEXT, 'False'::BOOLEAN, 'Tong'::TEXT, 'Chu'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('wenxuC2009'::TEXT, 'vyR1&K#D%'::TEXT, 'wenxu.2009@yahoo.com'::EMAIL, 'China'::TEXT, 'True'::BOOLEAN, 'Wenxue'::TEXT, 'Cen'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Mejiymdly1996'::TEXT, 'k4@FrD5I@6Y&3'::TEXT, 'm_1996@outlook.com'::EMAIL, 'China'::TEXT, 'True'::BOOLEAN, 'Mei'::TEXT, 'Jie'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('miaqia1999'::TEXT, 'oq#2BQu%F'::TEXT, 'm.q1999@yahoo.com'::EMAIL, 'China'::TEXT, 'False'::BOOLEAN, 'Miao'::TEXT, 'Qiao'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Yuqiy73399'::TEXT, 'hNO$a4&s1fI$#g9Dx3'::TEXT, 'yuqi.8018@yahoo.com'::EMAIL, 'Taiwan'::TEXT, 'True'::BOOLEAN, 'Yuqin'::TEXT, 'Yin'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('p_gwlvas2019'::TEXT, 'X3z@wVj6'::TEXT, 'pe_79@hotmail.com'::EMAIL, 'China'::TEXT, 'False'::BOOLEAN, 'Pei'::TEXT, 'Gan'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('zzl98'::TEXT, 's!5ZjW&@fa4X70&p'::TEXT, 'y.8@gmail.com'::EMAIL, 'China'::TEXT);
SELECT createAccount('Haironyo1982'::TEXT, 'xKu6Q@kTBcmo9!w'::TEXT, 'hy533@outlook.com'::EMAIL, 'China'::TEXT);
SELECT createAccount('xinmi_00'::TEXT, 'Y$4Xcrkn'::TEXT, 'xinmi_ya_n@gmail.com'::EMAIL, 'Japan'::TEXT);
SELECT createAccount('_end71736'::TEXT, 'b1MM!e4y2ASCM2TxCX%'::TEXT, 'conyo41@gmail.com'::EMAIL, 'Taiwan'::TEXT, 'False'::BOOLEAN, 'Cong'::TEXT, 'Yong'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('XiuCcvecc1975'::TEXT, 'Y%1Dpc50g1O&Vz5Vv'::TEXT, 'xiuxian_ch1975@outlook.com'::EMAIL, 'China'::TEXT);
SELECT createAccount('Puyspz1976'::TEXT, 'xfGW8%2%rVr4#V@y1!!'::TEXT, 'j_puyan3697@outlook.com'::EMAIL, 'Japan'::TEXT, 'False'::BOOLEAN, 'Jin'::TEXT, 'Puyang'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('_sxfjgt1995'::TEXT, 'wqR4A!9s#1um'::TEXT, 'shen_@hotmail.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Sheng'::TEXT, 'Shao'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Xuew_L212'::TEXT, 'qA&yE5@X45ww34'::TEXT, 'xuewe.la_n@gmail.com'::EMAIL, 'Japan'::TEXT);
SELECT createAccount('Jiahcft'::TEXT, 'oR5rR@@%0HEU$1'::TEXT, 'jia.2010@gmail.com'::EMAIL, 'China'::TEXT, 'False'::BOOLEAN, 'Jian'::TEXT, 'Gu'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Jiny_L56'::TEXT, 'nj3!NBTq!$2!&11N!$'::TEXT, 'jiny.l2001@gmail.com'::EMAIL, 'Japan'::TEXT);
SELECT createAccount('wWvbog2'::TEXT, 'Cu%Jk52V&K3dpl2p$3U'::TEXT, 'we_wa1985@outlook.com'::EMAIL, 'China'::TEXT, 'True'::BOOLEAN, 'Wei'::TEXT, 'Wang'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('xiaol_R043'::TEXT, 's0$IqU7W1s6'::TEXT, 'x_r0303@gmail.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Xiaolan'::TEXT, 'Ru'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('hongQigua1993'::TEXT, 'x6iDK##7fex&'::TEXT, 'hong.qi1993@outlook.com'::EMAIL, 'Taiwan'::TEXT, 'False'::BOOLEAN, 'Hongwei'::TEXT, 'Qiguan'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('pinYuezhe2006'::TEXT, 'ly%YY2r1k$KTd338#O'::TEXT, 'pingpiyuezhe346@hotmail.com'::EMAIL, 'China'::TEXT, 'False'::BOOLEAN, 'Pingping'::TEXT, 'Yuezheng'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('kan_lnga1'::TEXT, 'qz2$ZE3Ge'::TEXT, 'k._li@outlook.com'::EMAIL, 'Japan'::TEXT, 'False'::BOOLEAN, 'Kang'::TEXT, 'Ling'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('hail_Wan1978'::TEXT, 'l1wA&C!w6H2Wv$#U&'::TEXT, 'hail.wan@outlook.com'::EMAIL, 'China'::TEXT, 'False'::BOOLEAN, 'Hailin'::TEXT, 'Wang'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('xiu_orw'::TEXT, 'y$u7BOpB1'::TEXT, 'xiuzh.bi@gmail.com'::EMAIL, 'Hong Kong SAR China'::TEXT, 'False'::BOOLEAN, 'Xiuzhi'::TEXT, 'Bie'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Xiu_wvwzot2006'::TEXT, 'b3q&XQAgH9'::TEXT, 'xiuyu.w77741@gmail.com'::EMAIL, 'United States'::TEXT, 'False'::BOOLEAN, 'Xiuyun'::TEXT, 'Wen'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Ronzlvz7856'::TEXT, 'rp3CS&lrZ@mAE&g'::TEXT, 'ron.c5@gmail.com'::EMAIL, 'Taiwan'::TEXT);
SELECT createAccount('li_Guxoql2510'::TEXT, 'c0V!Dy@$hpB$48w2%#8'::TEXT, 'l_@outlook.com'::EMAIL, 'China'::TEXT, 'True'::BOOLEAN, 'Lin'::TEXT, 'Gui'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('miuga56'::TEXT, 'c4mH&H52pYrs@4B&X'::TEXT, 'mi.1991@outlook.com'::EMAIL, 'Hong Kong SAR China'::TEXT);
SELECT createAccount('phmr1980'::TEXT, 'mH2l&O6%AqeHDD4sV@14'::TEXT, 'l2734@gmail.com'::EMAIL, 'China'::TEXT, 'True'::BOOLEAN, 'Lifang'::TEXT, 'Pu'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Julia_1974'::TEXT, 'lq!C5Sc8s5%#5!c1#k!'::TEXT, 'j.mishi344@gmail.com'::EMAIL, 'Russia'::TEXT);
SELECT createAccount('fanzilj_Demide2002'::TEXT, 'MZ9@yyvjc@I4!#yW2%'::TEXT, 'fanzid2002@gmail.com'::EMAIL, 'Ukraine'::TEXT, 'False'::BOOLEAN, 'Fanzilja'::TEXT, 'Demidenko'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('halisgur885'::TEXT, 'l&4xBAsmk92ft'::TEXT, 'halis_g2011@yahoo.com'::EMAIL, 'Russia'::TEXT, 'True'::BOOLEAN, 'Halisa'::TEXT, 'Gurevich'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('_Aqqt1992'::TEXT, 'd$Jh6UG$#ImAp7Oh'::TEXT, 'appol.1992@outlook.com'::EMAIL, 'Russia'::TEXT, 'False'::BOOLEAN, 'Appolinari'::TEXT, 'Abramov'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Ksejkicr1991'::TEXT, 'TaJ5q%5C$3!RbQtG'::TEXT, 'ksenj.a_r_slan1991@hotmail.com'::EMAIL, 'Belarus'::TEXT, 'True'::BOOLEAN, 'Ksenja'::TEXT, 'Arslanov'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('ive_vun1978'::TEXT, 'gYk#A0NJla@5p!5&d%f'::TEXT, 'ivett.semenyu1978@outlook.com'::EMAIL, 'Russia'::TEXT, 'False'::BOOLEAN, 'Ivetta'::TEXT, 'Semenyuk'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('amirzjVlas1976'::TEXT, 'm7tFS!ma6u8d8Q'::TEXT, 'a.vla1976@gmail.com'::EMAIL, 'Ukraine'::TEXT, 'False'::BOOLEAN, 'Amirzjan'::TEXT, 'Vlasov'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('SamiErem62462'::TEXT, 'jiE@2U44P$vE2'::TEXT, 's72036@gmail.com'::EMAIL, 'Russia'::TEXT, 'False'::BOOLEAN, 'Samir'::TEXT, 'Eremenko'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('MitGol1996'::TEXT, 'l$4ZhF8b1D4v$'::TEXT, 'mitro.gol1996@gmail.com'::EMAIL, 'Russia'::TEXT, 'False'::BOOLEAN, 'Mitrofan'::TEXT, 'Golovin'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('IbragShin_k1'::TEXT, 'e1@aWF$$jBAj8T$o&'::TEXT, 'ibragi2021@gmail.com'::EMAIL, 'Russia'::TEXT, 'False'::BOOLEAN, 'Ibragim'::TEXT, 'Shinkevich'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Rav_ko2021'::TEXT, 'st7&CJuzH0lf'::TEXT, 'ravilj.kov2021@hotmail.com'::EMAIL, 'United States'::TEXT, 'True'::BOOLEAN, 'Ravilja'::TEXT, 'Kovtun'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Idri_Yushk1999'::TEXT, 'v1D#Wr$X&!v1@9'::TEXT, 'idri._yus1999@yahoo.com'::EMAIL, 'Russia'::TEXT, 'False'::BOOLEAN, 'Idris'::TEXT, 'Yushkevich'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('safBelo1981'::TEXT, 'i%l7VGBT9JNjz'::TEXT, 's.belo1981@yahoo.com'::EMAIL, 'Russia'::TEXT, 'False'::BOOLEAN, 'Safija'::TEXT, 'Belousov'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('Narkev2014'::TEXT, 'q4@mMS68zdjxBD'::TEXT, 'iri_n@gmail.com'::EMAIL, 'Russia'::TEXT, 'False'::BOOLEAN, 'Irik'::TEXT, 'Narkevich'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('parfOstrovski049'::TEXT, 'fbA5@BEeE@yXDkJjD'::TEXT, 'parf.ostr96@hotmail.com'::EMAIL, 'Russia'::TEXT);
SELECT createAccount('mago_Mikhe2004'::TEXT, 'rQ8pO!2g'::TEXT, 'magom.mik1071@hotmail.com'::EMAIL, 'Kazakhstan'::TEXT, 'False'::BOOLEAN, 'Magomet'::TEXT, 'Mikheev'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('sabirjFilip1990'::TEXT, 'k!a9DGS5!'::TEXT, 'sabirjafilipen@outlook.com'::EMAIL, 'Russia'::TEXT, 'True'::BOOLEAN, 'Sabirjan'::TEXT, 'Filipenko'::TEXT, NULL, 'User'::TEXT);
SELECT createAccount('azafcslm1991'::TEXT, 'F2kwF&ud7BZ2u'::TEXT, 'aza_sh04015@gmail.com'::EMAIL, 'Belarus'::TEXT);

SELECT verifyUser(1);
SELECT verifyUser(2);
SELECT verifyUser(3);
SELECT verifyUser(4);
SELECT verifyUser(5);
SELECT verifyUser(6);
SELECT verifyUser(7);
SELECT verifyUser(8);
SELECT verifyUser(9);
SELECT verifyUser(10);
SELECT verifyUser(11);
SELECT verifyUser(12);
SELECT verifyUser(13);
SELECT verifyUser(14);
SELECT verifyUser(15);
SELECT verifyUser(16);
SELECT verifyUser(17);
SELECT verifyUser(18);
SELECT verifyUser(19);
SELECT verifyUser(20);
SELECT verifyUser(21);
SELECT verifyUser(22);
SELECT verifyUser(23);
SELECT verifyUser(24);
SELECT verifyUser(25);
SELECT verifyUser(26);
SELECT verifyUser(27);
SELECT verifyUser(28);
SELECT verifyUser(29);
SELECT verifyUser(30);
SELECT verifyUser(31);
SELECT verifyUser(32);
SELECT verifyUser(33);
SELECT verifyUser(34);
SELECT verifyUser(35);
SELECT verifyUser(36);
SELECT verifyUser(37);
SELECT verifyUser(38);
SELECT verifyUser(39);
SELECT verifyUser(40);
SELECT verifyUser(41);
SELECT verifyUser(42);
SELECT verifyUser(43);
SELECT verifyUser(44);
SELECT verifyUser(45);
SELECT verifyUser(46);
SELECT verifyUser(47);
SELECT verifyUser(48);
SELECT verifyUser(49);
SELECT verifyUser(50);
SELECT verifyUser(51);
SELECT verifyUser(52);
SELECT verifyUser(53);
SELECT verifyUser(54);
SELECT verifyUser(55);
SELECT verifyUser(56);
SELECT verifyUser(57);
SELECT verifyUser(58);
SELECT verifyUser(59);
SELECT verifyUser(60);
SELECT verifyUser(61);
SELECT verifyUser(62);
SELECT verifyUser(63);
SELECT verifyUser(64);
SELECT verifyUser(65);
SELECT verifyUser(66);
SELECT verifyUser(67);
SELECT verifyUser(68);
SELECT verifyUser(69);
SELECT verifyUser(70);
SELECT verifyUser(71);
SELECT verifyUser(72);
SELECT verifyUser(73);
SELECT verifyUser(74);
SELECT verifyUser(75);
SELECT verifyUser(76);
SELECT verifyUser(77);
SELECT verifyUser(78);
SELECT verifyUser(79);
SELECT verifyUser(80);
SELECT verifyUser(81);
SELECT verifyUser(82);
SELECT verifyUser(83);
SELECT verifyUser(84);
SELECT verifyUser(85);
SELECT verifyUser(86);
SELECT verifyUser(87);
SELECT verifyUser(88);
SELECT verifyUser(89);
SELECT verifyUser(90);
SELECT verifyUser(91);
SELECT verifyUser(92);
SELECT verifyUser(93);
SELECT verifyUser(94);
SELECT verifyUser(95);
SELECT verifyUser(96);
SELECT verifyUser(97);
SELECT verifyUser(98);
SELECT verifyUser(99);
SELECT verifyUser(100);

CALL createContest('Programowanie Nieobiektowe'::text, '2023-06-08 21:13:54.116602+02', '1 day', '1, 2, 3, 4'::text, 4);
CALL createContest('Inżynieria Danych'::text, '2023-05-08 23:12:54.116602+02', '1 hour', '1, 5, 2, 4'::text, 5);
CALL createContest('Nauka jedzenia'::text, '2025-03-08 21:13:54.116602+02', '1 day', '1, 2, 4'::text, 18);
CALL createContest('Programowanie z funem'::text, '2024-02-08 23:13:54.116602+02', '1 year', '1, 2, 3, 4'::text, 2);
CALL createContest('Oglądanie filmow'::text, '2023-01-08 23:13:54.116602+02', '1 hour', '1, 23, 32, 4'::text, 2);
CALL createContest('Wiecej nauki'::text, '2025-06-08 23:13:54.116602+02', '1 year', '5, 35, 2, 3, 4'::text, 14);
CALL createContest('Nauka do konkursu'::text, '2023-05-08 23:13:54.116602+02', '1 hour', '1, 12, 13'::text, 23);
CALL createContest('Matematyka NIE Dyskretna'::text, '2023-02-08 14:13:54.116602+02', '1 hour', '21, 22, 3, 34'::text, 44);
CALL createContest('Podstawy Programowania'::text, '2024-02-08 15:13:24.116602+02', '1 year', '11, 2, 3, 4'::text, 1);
CALL createContest('Programowanie'::text, '2024-01-08 23:13:54.116602+02', '1 hour', '31, 42, 4'::text, 14);