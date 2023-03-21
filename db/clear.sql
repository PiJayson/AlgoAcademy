/*******************************************************************************
   algo.academy
   Script: uninstall.sql
   Description: Uninstalls algo.academy database.
   DB Server: PostgreSQL
   Authors: Radosław Myśliwiec, Michał Miziołek, Vladislav Kozulin
********************************************************************************/

/*******************************************************************************
   Drop Rules
********************************************************************************/

DROP RULE IF EXISTS "Difficulty_ForbidInsertion" ON "Difficulty" CASCADE;
DROP RULE IF EXISTS "Difficulty_ForbidUpdate" ON "Difficulty" CASCADE;
DROP RULE IF EXISTS "Difficulty_ForbidDeletion" ON "Difficulty" CASCADE;
DROP RULE IF EXISTS "Role_ForbidInsertion" ON "Role" CASCADE;
DROP RULE IF EXISTS "Role_ForbidUpdate" ON "Role" CASCADE;
DROP RULE IF EXISTS "Role_ForbidDeletion" ON "Role" CASCADE;
DROP RULE IF EXISTS "Country_ForbidInsertion" ON "Country" CASCADE;
DROP RULE IF EXISTS "Country_ForbidUpdate" ON "Country" CASCADE;
DROP RULE IF EXISTS "Country_ForbidDeletion" ON "Country" CASCADE;
DROP RULE IF EXISTS "ProgrammingLanguage_ForbidInsertion" ON "ProgrammingLanguage" CASCADE;
DROP RULE IF EXISTS "ProgrammingLanguage_ForbidUpdate" ON "ProgrammingLanguage" CASCADE;
DROP RULE IF EXISTS "ProgrammingLanguage_ForbidDeletion" ON "ProgrammingLanguage" CASCADE;
DROP RULE IF EXISTS "Result_ForbidInsertion" ON "Result" CASCADE;
DROP RULE IF EXISTS "Result_ForbidUpdate" ON "Result" CASCADE;
DROP RULE IF EXISTS "Result_ForbidDeletion" ON "Result" CASCADE;
DROP RULE IF EXISTS "Tag_ForbidInsertion" ON "Tag" CASCADE;
DROP RULE IF EXISTS "Tag_ForbidUpdate" ON "Tag" CASCADE;
DROP RULE IF EXISTS "Tag_ForbidDeletion" ON "Tag" CASCADE;
DROP RULE IF EXISTS "TagPrerequisite_ForbidInsertion" ON "TagPrerequisite" CASCADE;
DROP RULE IF EXISTS "TagPrerequisite_ForbidUpdate" ON "TagPrerequisite" CASCADE;
DROP RULE IF EXISTS "TagPrerequisite_ForbidDeletion" ON "TagPrerequisite" CASCADE;
DROP RULE IF EXISTS "TagCategory_ForbidInsertion" ON "TagCategory" CASCADE;
DROP RULE IF EXISTS "TagCategory_ForbidUpdate" ON "TagCategory" CASCADE;
DROP RULE IF EXISTS "TagCategory_ForbidDeletion" ON "TagCategory" CASCADE;
DROP RULE IF EXISTS "User_ForbidDeletion" ON "User" CASCADE;

/*******************************************************************************
   Drop Foreign Keys
********************************************************************************/

ALTER TABLE IF EXISTS "User" DROP CONSTRAINT IF EXISTS "FK_User_RoleId" CASCADE;
ALTER TABLE IF EXISTS "User" DROP CONSTRAINT IF EXISTS "FK_User_CountryId" CASCADE;
ALTER TABLE IF EXISTS "Contest" DROP CONSTRAINT IF EXISTS "FK_Contest_AuthorId" CASCADE; -- !!!
ALTER TABLE IF EXISTS "ContestProblem" DROP CONSTRAINT IF EXISTS "FK_ContestProblem_ContestId" CASCADE;
ALTER TABLE IF EXISTS "ContestProblem" DROP CONSTRAINT IF EXISTS "FK_ContestProblem_ProblemId" CASCADE;
ALTER TABLE IF EXISTS "ContestSubmission" DROP CONSTRAINT IF EXISTS "FK_ContestSubmission_ContestId" CASCADE;
ALTER TABLE IF EXISTS "ContestSubmission" DROP CONSTRAINT IF EXISTS "FK_ContestSubmission_SubmissionId" CASCADE;
ALTER TABLE IF EXISTS "Registration" DROP CONSTRAINT IF EXISTS "FK_Registration_UserId" CASCADE;
ALTER TABLE IF EXISTS "Registration" DROP CONSTRAINT IF EXISTS "FK_Registration_ContestId" CASCADE;
ALTER TABLE IF EXISTS "Submission" DROP CONSTRAINT IF EXISTS "FK_Submission_UserId" CASCADE;
ALTER TABLE IF EXISTS "Submission" DROP CONSTRAINT IF EXISTS "FK_Submission_ProblemId" CASCADE;
ALTER TABLE IF EXISTS "Submission" DROP CONSTRAINT IF EXISTS "FK_Submission_ProgrammingLanguageId" CASCADE;
ALTER TABLE IF EXISTS "Submission" DROP CONSTRAINT IF EXISTS "FK_Submission_ResultId" CASCADE;
ALTER TABLE IF EXISTS "OfficialSolution" DROP CONSTRAINT IF EXISTS "FK_OfficialSolution_SubmissionId" CASCADE;
ALTER TABLE IF EXISTS "Problem" DROP CONSTRAINT IF EXISTS "FK_Problem_SourceId" CASCADE;
ALTER TABLE IF EXISTS "Subtask" DROP CONSTRAINT IF EXISTS "FK_Subtask_ProblemId" CASCADE;
ALTER TABLE IF EXISTS "Test" DROP CONSTRAINT IF EXISTS "FK_Test_SubtaskId" CASCADE;
ALTER TABLE IF EXISTS "Test" DROP CONSTRAINT IF EXISTS "FK_Test_ResultId" CASCADE;
ALTER TABLE IF EXISTS "Hint" DROP CONSTRAINT IF EXISTS "FK_Hint_ProblemId" CASCADE;
ALTER TABLE IF EXISTS "UserProblemHint" DROP CONSTRAINT IF EXISTS "FK_UserProblemHind_UserId" CASCADE;
ALTER TABLE IF EXISTS "UserProblemHint" DROP CONSTRAINT IF EXISTS "FK_UserProblemHind_ProblemId" CASCADE;
ALTER TABLE IF EXISTS "UserProblemsSolved" DROP CONSTRAINT IF EXISTS "FK_UserProblemsSolved_UserId" CASCADE;
ALTER TABLE IF EXISTS "UserProblemsSolved" DROP CONSTRAINT IF EXISTS "FK_UserProblemsSolved_ProblemId" CASCADE;
ALTER TABLE IF EXISTS "ProblemTag" DROP CONSTRAINT IF EXISTS "FK_ProblemTag_TagId" CASCADE;
ALTER TABLE IF EXISTS "ProblemTag" DROP CONSTRAINT IF EXISTS "FK_ProblemTag_ProblemId" CASCADE;
ALTER TABLE IF EXISTS "TagPrerequisite" DROP CONSTRAINT IF EXISTS "FK_TagPrerequisite_ParentTagId" CASCADE;
ALTER TABLE IF EXISTS "TagPrerequisite" DROP CONSTRAINT IF EXISTS "FK_TagPrerequisite_TagId" CASCADE;
ALTER TABLE IF EXISTS "TagCategory" DROP CONSTRAINT IF EXISTS "FK_TagCategory_ParentTagId" CASCADE;
ALTER TABLE IF EXISTS "TagCategory" DROP CONSTRAINT IF EXISTS "FK_TagCategory_TagId" CASCADE;
ALTER TABLE IF EXISTS "ProblemTag" DROP CONSTRAINT IF EXISTS "FK_ProblemTag_DifficultyId" CASCADE;
ALTER TABLE IF EXISTS "SubmissionTest" DROP CONSTRAINT IF EXISTS "FK_SubmissionTest_SubmissionId" CASCADE;
ALTER TABLE IF EXISTS "SubmissionTest" DROP CONSTRAINT IF EXISTS "FK_SubmissionTest_TestId" CASCADE;
ALTER TABLE IF EXISTS "SubmissionTest" DROP CONSTRAINT IF EXISTS "FK_SubmissionTest_ResultId" CASCADE;

/*******************************************************************************
   Drop Tables
********************************************************************************/

DROP TABLE IF EXISTS "Difficulty" CASCADE;
DROP TABLE IF EXISTS "Role" CASCADE;
DROP TABLE IF EXISTS "Country" CASCADE;
DROP TABLE IF EXISTS "User" CASCADE;
DROP TABLE IF EXISTS "Contest" CASCADE;
DROP TABLE IF EXISTS "Registration" CASCADE;
DROP TABLE IF EXISTS "ProgrammingLanguage" CASCADE;
DROP TABLE IF EXISTS "Result" CASCADE;
DROP TABLE IF EXISTS "Submission" CASCADE;
DROP TABLE IF EXISTS "OfficialSolution" CASCADE;
DROP TABLE IF EXISTS "Source" CASCADE;
DROP TABLE IF EXISTS "Problem" CASCADE;
DROP TABLE IF EXISTS "Subtask" CASCADE;
DROP TABLE IF EXISTS "SubmissionTest" CASCADE;
DROP TABLE IF EXISTS "Test" CASCADE;
DROP TABLE IF EXISTS "Hint" CASCADE;
DROP TABLE IF EXISTS "UserProblemHint" CASCADE;
DROP TABLE IF EXISTS "UserProblemsSolved" CASCADE;
DROP TABLE IF EXISTS "Tag" CASCADE;
DROP TABLE IF EXISTS "ProblemTag" CASCADE;
DROP TABLE IF EXISTS "TagPrerequisite" CASCADE;
DROP TABLE IF EXISTS "TagCategory" CASCADE;
DROP TABLE IF EXISTS "ContestProblem" CASCADE;
DROP TABLE IF EXISTS "ContestSubmission" CASCADE;

/*******************************************************************************
   Drop Functions
********************************************************************************/

DROP FUNCTION IF EXISTS wasUserRegistered(INTEGER) CASCADE;
DROP FUNCTION IF EXISTS wasUserRegistered(EMAIL) CASCADE;
DROP FUNCTION IF EXISTS wasUserRegistered(TEXT) CASCADE;

DROP FUNCTION IF EXISTS isUserActive(INTEGER) CASCADE;
DROP FUNCTION IF EXISTS isUserActive(EMAIL) CASCADE;
DROP FUNCTION IF EXISTS isUserActive(TEXT) CASCADE;

DROP FUNCTION IF EXISTS isUserTemporarilyDeleted(INTEGER) CASCADE;
DROP FUNCTION IF EXISTS isUserTemporarilyDeleted(EMAIL) CASCADE;
DROP FUNCTION IF EXISTS isUserTemporarilyDeleted(TEXT) CASCADE;

DROP FUNCTION IF EXISTS isUserPermanentlyDeleted(INTEGER) CASCADE;
DROP FUNCTION IF EXISTS isUserPermanentlyDeleted(EMAIL) CASCADE;
DROP FUNCTION IF EXISTS isUserPermanentlyDeleted(TEXT) CASCADE;

DROP FUNCTION IF EXISTS isUserVerified(INTEGER) CASCADE;
DROP FUNCTION IF EXISTS isUserVerified(EMAIL) CASCADE;
DROP FUNCTION IF EXISTS isUserVerified(TEXT) CASCADE;

DROP FUNCTION IF EXISTS isEmailTaken(EMAIL) CASCADE;

DROP FUNCTION IF EXISTS isUsernameTaken(TEXT) CASCADE;

DROP FUNCTION IF EXISTS verifyUser(INTEGER) CASCADE;
DROP FUNCTION IF EXISTS verifyUser(TEXT) CASCADE;

DROP FUNCTION IF EXISTS getUserId(TEXT) CASCADE;

DROP FUNCTION IF EXISTS createAccount(TEXT, TEXT, EMAIL, TEXT, BOOLEAN, TEXT, TEXT, TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS createAccount(TEXT, TEXT, EMAIL, INTEGER, BOOLEAN, TEXT, TEXT, TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS createAccount(TEXT, TEXT, EMAIL, TEXT, BOOLEAN, TEXT, TEXT, TEXT, INTEGER) CASCADE;
DROP FUNCTION IF EXISTS createAccount(TEXT, TEXT, EMAIL, INTEGER, BOOLEAN, TEXT, TEXT, TEXT, INTEGER) CASCADE;

DROP FUNCTION IF EXISTS login(TEXT, TEXT) CASCADE;

DROP FUNCTION IF EXISTS deleteAccount(INTEGER) CASCADE;

DROP FUNCTION IF EXISTS restoreAccount(INTEGER) CASCADE;

DROP FUNCTION IF EXISTS showRanking() CASCADE;

DROP FUNCTION IF EXISTS User_ValidateInsert() CASCADE;
DROP FUNCTION IF EXISTS User_ValidateUpdate() CASCADE;

DROP FUNCTION IF EXISTS doesProblemExist(INTEGER) CASCADE;

DROP FUNCTION IF EXISTS doesContestExist(INTEGER) CASCADE;
DROP FUNCTION IF EXISTS doesContestExist(TEXT) CASCADE;

DROP FUNCTION IF EXISTS getContestId(TEXT) CASCADE;

DROP PROCEDURE IF EXISTS createContest(TEXT, TIMESTAMPTZ, INTERVAL, TEXT, INTEGER, TEXT, BOOLEAN, BOOLEAN) CASCADE;

DROP FUNCTION IF EXISTS countContestProblems(INTEGER) CASCADE;

DROP PROCEDURE IF EXISTS deleteContest(INTEGER) CASCADE;

DROP FUNCTION IF EXISTS Contest_ValidateInsert() CASCADE;
DROP FUNCTION IF EXISTS Contest_ValidateInsertDeferred() CASCADE;
DROP FUNCTION IF EXISTS Contest_ValidateUpdate() CASCADE;
DROP FUNCTION IF EXISTS Contest_ValidateDelete() CASCADE;

DROP FUNCTION IF EXISTS register(INTEGER, INTEGER) CASCADE;

DROP FUNCTION IF EXISTS isRegistered(INTEGER, INTEGER) CASCADE;

DROP FUNCTION IF EXISTS showRegistered(INTEGER) CASCADE;

DROP FUNCTION IF EXISTS doesProgrammingLanguageExist(INTEGER) CASCADE;

DROP FUNCTION IF EXISTS getContestStartTime(INTEGER) CASCADE;
DROP FUNCTION IF EXISTS getContestEndTime(INTEGER) CASCADE;

DROP PROCEDURE IF EXISTS submit(INTEGER, INTEGER, INTEGER, INTEGER, TEXT) CASCADE;

DROP FUNCTION IF EXISTS Submission_CheckInsert() CASCADE;
DROP FUNCTION IF EXISTS Submission_CheckUpdate() CASCADE;

DROP FUNCTION IF EXISTS sumProblemPoints(INTEGER) CASCADE;

DROP PROCEDURE IF EXISTS insertProblemTag(INTEGER, TEXT) CASCADE;

DROP PROCEDURE IF EXISTS addProblem(TEXT, TEXT, INTEGER, INTEGER, INTEGER, TEXT, TEXT, BOOLEAN, TEXT) CASCADE;

DROP FUNCTION IF EXISTS Problem_CheckInsert() CASCADE;
DROP FUNCTION IF EXISTS Problem_CheckUpdate() CASCADE;
DROP FUNCTION IF EXISTS Problem_CheckDelete() CASCADE;

DROP FUNCTION IF EXISTS showSubmits() CASCADE;

/*******************************************************************************
   Drop Views
********************************************************************************/

DROP VIEW IF EXISTS showProblems CASCADE;

/*******************************************************************************
   Drop Triggers
********************************************************************************/

DROP TRIGGER IF EXISTS "User_ValidateInsert" ON "User" CASCADE;
DROP TRIGGER IF EXISTS "User_ValidateUpdate" ON "User" CASCADE;

DROP TRIGGER IF EXISTS "Contest_ValidateInsert" ON "Contest" CASCADE;
DROP TRIGGER IF EXISTS "Contest_ValidateInsertDeferred" ON "Contest" CASCADE;
DROP TRIGGER IF EXISTS "Contest_ValidateUpdate" ON "Contest" CASCADE;
DROP TRIGGER IF EXISTS "Contest_ValidateDelete" ON "Contest" CASCADE;

DROP TRIGGER IF EXISTS "Submission_CheckInsert" ON "Submission" CASCADE;
DROP TRIGGER IF EXISTS "Submission_CheckUpdate" ON "Submission" CASCADE;

DROP TRIGGER IF EXISTS "Problem_CheckInsert" ON "Problem" CASCADE;
DROP TRIGGER IF EXISTS "Problem_CheckUpdate" ON "Problem" CASCADE;
DROP TRIGGER IF EXISTS "Problem_CheckDelete" ON "Problem" CASCADE;

/*******************************************************************************
   Drop Domains
********************************************************************************/

DROP DOMAIN IF EXISTS EMAIL CASCADE;