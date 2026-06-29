package com.finalproject.Final.repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import com.finalproject.Final.model.UsersBean;

import jakarta.validation.Valid;



@Repository
public class UsersRepository {
	@Autowired
	JdbcTemplate jdbc;
	
	public int insertUser(UsersBean obj) {
		int i=0;
		
		
		String sql="INSERT INTO `student_mgmt_v6`.`user` (`role_id`, `name`, `email`, `password`, `phone_no`, `address`,`dob`, `gender`,`created_at`,`is_active`,`file_path`)\r\n"
				+ " VALUES (?,?,?,?,?,?,?,?,?,?,?)";
		
		i=jdbc.update(sql,obj.getRoleId(),obj.getName(),obj.getEmail(),obj.getPassword()
				,obj.getPhoneNumber(),obj.getAddress(),obj.getDob(),
				obj.getGender(),obj.getCreatedAt(),obj.getIsActive(),obj.getFilePath());
	
		return i;
	}
	
	public boolean existsByEmail(String email) {

	    String sql = "SELECT COUNT(*) FROM user WHERE email = ?";
	    Integer count = jdbc.queryForObject(sql, Integer.class,email);

	    return count != null && count > 0;
	}

}
		
	
	



