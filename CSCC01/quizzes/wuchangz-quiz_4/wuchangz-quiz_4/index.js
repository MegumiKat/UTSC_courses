import express from "express";
import bodyParser from "body-parser";
import db from "./db_utils/db.js";
import { sequelize } from "./datasource.js";

const app = express();
const PORT = 3000;
try {
  await sequelize.authenticate();
  // Automatically detect all of your defined models and create (or modify) the tables for you.
  // This is not recommended for production-use, but that is a topic for a later time!
  await sequelize.sync({ alter: { drop: false } });
  console.log("Connection has been established successfully.");
} catch (error) {
  console.error("Unable to connect to the database:", error);
}


app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

// IMPORTANT!! PUT YOUR UTORID HERE
app.get("/me", (req, res) => {
  return res.status(200).json({ utorid: "wuchangz" });
});

/*

// You can use the db helper class to interact with the database,
if you don't want to run raw sequelize. See the /db_utils/db.js file for more informationrmation.

// Example of using the db helper class to get all students
app.get("/students", async (req, res) => {
    const students = await db.getAllStudents();
    return res.status(200).json(students);
});

// Example of using the db helper class to get a student by id
app.get("/students/:id", async (req, res) => {
    const student = await db.getStudentById(req.params.id);
    return res.status(200).json(student);
});


IMPORTANT! USE THIS CLASS AT YOUR OWN RISK, AND MAKE SURE TO ERROR HANDLE PROPERLY!
THERE'S NO INPUT VALIDATION, OR ERROR HANDLING IN THIS CLASS, SO IT'S UP TO YOU TO IMPLEMENT IT.
*/


// INSERT YOUR ENDPOINTS BELOW //

app.post('/api/courses', async (req, res) => {
  const coursedata = req.body;
  if (!coursedata.code || !coursedata.name || !coursedata.session || !coursedata.department) {
    return res.status(404).json({ error: 'Every element is required' });
  }
  try {
    const course = await db.addCourse(coursedata.code, coursedata.name, coursedata.session, coursedata.department);
    return res.status(200).json({
      course: {
        'id': course.id,
        'code': course.courseCode,
        'name': course.courseName,
        'session': course.session,
        'department': course.department
      }
    });
  } catch (error) {
    return res.status(404).json({ error: 'err' });
  }
});

app.get('/api/courses', async (req, res) => {
  try {
    const information = req.query;
    const courses = await db.getCourses(information.session, information.department);
    return res.status(200).json({ courses });
  } catch (error) {
    return res.status(404).json({ error: 'err' });
  }
});

app.get('/api/courses/:courseId/students', async (req, res) => {
  try {
    const courseId = req.params.courseId;
    const students = await db.getStudentsByCourse(courseId);
    return res.status(200).json({ students });
  } catch (error) {
    return res.status(404).json({ error: 'err' });
  }
});

app.post('/api/courses/:courseId/students', async (req, res) => {
  try {
    const { student } = req.body;
    const courseId = req.params.courseId;
    const enrolment = await db.enrolStudent(courseId, student);
    return res.status(200).json({ enrolment });
  } catch (error) {
    return res.status(404).json({ error: 'err' });
  }
});

app.patch('/api/courses/:courseId/students/:studentId/grade', async (req, res) => {
  try {
    const { courseId, studentId } = req.params
    const { finalGrade } = req.body;
    const enrolment = await db.updateGrade(courseId, studentId, finalGrade);
    return res.status(200).json({ enrolment });
  } catch (error) {
    return res.status(404).json({ error: 'err' });
  }
})

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});