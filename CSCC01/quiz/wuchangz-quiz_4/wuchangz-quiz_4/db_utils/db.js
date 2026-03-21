import {Student} from "../models/students.js";
import {Course} from "../models/courses.js";
import { Enrolment } from "../models/enrolment.js";

async function getStudentById(studentId){
    return await Student.findByPk(studentId);
}

async function getStudentsByCourse(courseId){
    return await Enrolment.findAll({ where: {CourseId: courseId}, include: { association: "Student"}});
}

async function getAllStudents(){
    return await Student.findAll();
}

async function getEnrolment(studentId, courseId){
    return await Enrolment.findOne({ where: {StudentId: studentId, CourseId: courseId}});
}

function addStudent(firstName, lastName, phoneNumber){
    return Student.create({
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber
    });
}

async function getCourseById(courseId){
    return await Course.findByPk(courseId);
}

async function getCourseByCodeAndSession(courseCode, session){
    return await Course.findAll({ where:{courseCode: courseCode, session: session} });
}

function getCourses(session, department){
    let whereClause = {};
    if(session){
        whereClause.session = session;
    }
    if(department){
        whereClause.department = department;
    }
    return Course.findAll({ where: whereClause});
}

async function addCourse(courseCode, courseName, session, department){
    return await Course.create({
        courseCode: courseCode,
        courseName: courseName,
        session: session,
        department: department
    });;
}


async function enrolStudent(courseId, studentId){
    return await Enrolment.create({
        CourseId: courseId,
        StudentId: studentId
    });
}

async function updateGrade(courseId, studentId, grade){
    let enrolment = await getEnrolment(studentId, courseId);
    enrolment.finalGrade = grade;
    return await enrolment.save();
}

async function updateStudent(studentId, firstName, lastName, phoneNumber){
    let student = await Student.findByPk(studentId);
    student.firstName = firstName;
    student.lastName = lastName;
    student.phoneNumber = phoneNumber;
    return await student.save();
}

async function deleteStudent(studentId){
    const student = await Student.findByPk(studentId);
    await student.destroy();
    return student;
}

export default {
    getStudentById,
    getStudentsByCourse,
    addStudent,
    getCourseById,
    getCourseByCodeAndSession,
    getCourses,
    addCourse,
    enrolStudent,
    updateStudent,
    deleteStudent,
    getAllStudents,
    getEnrolment,
    updateGrade
};