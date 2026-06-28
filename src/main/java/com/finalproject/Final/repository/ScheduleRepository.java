package com.finalproject.Final.repository;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import com.finalproject.Final.model.ScheduleBean;

@Repository
public class ScheduleRepository {
	
	@Autowired
	private JdbcTemplate jdbc;
	
	public List<ScheduleBean> findByCourseId(int courseId) {

	    String sql =
	        "SELECT * FROM schedule WHERE course_id = ?";

	    return jdbc.query(sql, new ScheduleRowMapper(), courseId);
	}

}
