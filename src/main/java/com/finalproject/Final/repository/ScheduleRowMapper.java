package com.finalproject.Final.repository;

import java.sql.ResultSet;
import java.sql.SQLException;

import org.springframework.jdbc.core.RowMapper;

import com.finalproject.Final.model.ScheduleBean;

public class ScheduleRowMapper implements RowMapper<ScheduleBean> {

    @Override
    public ScheduleBean mapRow(ResultSet rs, int rowNum) throws SQLException {

        ScheduleBean schedule = new ScheduleBean();

        schedule.setId(rs.getInt("id"));
        schedule.setCourseId(rs.getInt("course_id"));

        schedule.setDate(rs.getDate("date").toLocalDate());
        schedule.setStartTime(rs.getTime("start_time").toLocalTime());
        schedule.setEndTime(rs.getTime("end_time").toLocalTime());

        schedule.setRoom(rs.getString("room"));

        return schedule;
    }

}