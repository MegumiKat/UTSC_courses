import { DataTypes } from "sequelize";
import { sequelize } from "../datasource.js";
import { Student } from "./students.js";
import { Course } from "./courses.js";

export const Enrolment = sequelize.define("Enrolment", {
    finalGrade:{
        type: DataTypes.INTEGER,
        allowNull: true,
    }
});

Course.hasMany(Enrolment);
Student.hasMany(Enrolment);
Enrolment.belongsTo(Course);
Enrolment.belongsTo(Student);

