import { sequelize } from "../datasource.js";
import { DataTypes } from "sequelize";

// This is bad database design, but we'll do this to simplify the quiz.
export const Course = sequelize.define("Course", {
    courseCode: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    courseName: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    department: { // EG: CSC, MAT, BIO
        type: DataTypes.STRING,
        allowNull: false,
    },
    session:{ // EG: S24, F24, S23. 
        type: DataTypes.STRING,
        allowNull: false,
    },
});