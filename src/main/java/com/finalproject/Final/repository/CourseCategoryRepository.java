package com.finalproject.Final.repository;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import com.finalproject.Final.dto.CourseCategoryDTO;
import com.finalproject.Final.model.CourseCategoryBean;



/**
 * 
 * Course Category CRUD
 * 
 * @author WYTM
 *
 */


@Repository
public class CourseCategoryRepository {

	@Autowired
	JdbcTemplate jdbc;
	
	public int createdCourseCategory(CourseCategoryDTO courseCategory) {
		
		String sql = "insert into course_category (name) values (?)";
		
		return jdbc.update(sql,courseCategory.getName());
		
	}
	
	
	public List<CourseCategoryBean> getAllCourseCategory(){
		
		
		
		String sql = "select * from course_category";
		
		return jdbc.query(sql, 
				(rs,rowCont) -> new CourseCategoryBean(
						rs.getInt("id"),
						rs.getString("name")
						)
				);
		
	}
	
	public CourseCategoryBean getCourseCategoryById(int courseCategoryId) {
		
		String sql = "select * from course_category where id=?";
		
		return jdbc.queryForObject(sql,
				(rs,rowCount)-> new CourseCategoryBean(
						rs.getInt("id"),
						rs.getString("name"))
				,courseCategoryId );
	}
	
	public int updateCourseCategory(int CourseCatId, String courseCatName) {
		
		String sql = "update course_category set name=? where id=?";
		
		return  jdbc.update(sql,courseCatName,CourseCatId);
		
	}
	
	public int deleteCourseCategory(int courseCategoryId) {
		
		String sql = "delete from course_category where id=?";
		
		return jdbc.update(sql,courseCategoryId);
	}
}
