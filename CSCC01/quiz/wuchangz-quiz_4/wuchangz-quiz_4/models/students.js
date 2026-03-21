import { DataTypes } from "sequelize";
import { sequelize } from "../datasource.js";

export const Student = sequelize.define("Student", {
    firstName: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    lastName: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    phoneNumber: {
        type: DataTypes.STRING,
        allowNull: false,
    }
});