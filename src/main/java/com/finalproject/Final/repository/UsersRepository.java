package com.finalproject.Final.repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
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
		
		
		String sql="INSERT INTO `user` (`role_id`, `name`, `email`, `password`, `phone_no`, `address`,`dob`, `gender`,`created_at`,`is_active`,`file_path`)\r\n"
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

	
	public UsersBean getLatestStudent() {

	    String sql = "SELECT * FROM user WHERE role_id = 3 ORDER BY id DESC LIMIT 1";

	    return jdbc.queryForObject(
	            sql,
	            (rs, rowNum) -> new UsersBean(
	            		rs.getInt("id"),
	                    rs.getInt("role_id"),
	                    rs.getString("name"),
	                    rs.getString("email"),
	                    rs.getString("password"),
	                    rs.getString("phone_no"),
	                    rs.getString("address"),
	                    rs.getDate("dob").toLocalDate(),
	                    rs.getString("gender"),
	                    rs.getTimestamp("created_at").toLocalDateTime(),
	                    rs.getInt("is_active"),
	                    rs.getString("file_path")
	            )
	    );
	}
	
	
	
	           
	public int updateUser(UsersBean userObj) {
		
		//String sql="update user set"
			//	+ " name=?,email=?,password=?,"
			//	+ " phone_no=?,address=?,dob=?,gender=?,file_path=? where id=?";
		
		
		String sql="UPDATE `user` SET `name` = ?, `email` = ?,"
				+ " `password` = ?, `phone_no` = ?, `address` = ?, `dob` = ?, "
				+ "`gender` = ?, `file_path` = ? WHERE (`id` = ?)";
			
			return	jdbc.update(sql,userObj.getName(),userObj.getEmail(),
					userObj.getPassword(),userObj.getPhoneNumber(),
					userObj.getAddress(),userObj.getDob(),userObj.getGender()
					,userObj.getFilePath(),userObj.getId());
		
		
	}
	      
	
	public UsersBean getUserByEmail(String email) {

	    String sql = "SELECT * FROM user WHERE email=?";

	    try {
	        return jdbc.queryForObject(
	                sql,
	                new BeanPropertyRowMapper<>(UsersBean.class),
	                email);

	    } catch (Exception e) {
	        return null;
	    }
	}
	   
	
	public UsersBean getUserById(int id) {

	    String sql = "SELECT * FROM user WHERE id = ?";

	    try {

	        return jdbc.queryForObject(
	                sql,
	                new BeanPropertyRowMapper<>(UsersBean.class),
	                id);

	    } catch (Exception e) {

	        return null;

	    }

	}
}
		
	
	



