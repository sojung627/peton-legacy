package com.example.db.controller;

import java.io.File;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import com.example.db.dao.MemberDao;
import com.example.db.vo.MemberProfileVo;
import com.example.db.vo.MemberVo;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;


@Controller
public class MemberProfileController {
	
	@Autowired
	MemberDao memberDao;
	
	@Autowired
    HttpServletRequest request;
    
    @Autowired
    HttpSession session;
	
	// myInfo.jsp - 회원정보 창 띄우기
	@RequestMapping("/profile/myInfo.do")
	public String myInfo() {
		
		return "profile/myInfo";
	}
	
	
	// myProfile.jsp - 내 프로필 창 띄우기
	@RequestMapping("/profile/myProfile.do")
	public String myProfile(HttpSession session,
	                        Model model,
	                        HttpServletRequest request) {

	    MemberVo user = (MemberVo) session.getAttribute("user");
	    if (user == null) {
	        return "redirect:/login.do";
	    }

	    // 프로필 정보 조회 (DAO 메서드 이름은 너 프로젝트에 맞게 변경)
	    MemberProfileVo profile = memberDao.selectProfileByMemIdx(user.getMem_idx());

	    String contextPath = request.getContextPath();
	    // 프사 없을 때 기본 이미지 (static/img/noprofile.jpg)
	    String defaultImg = contextPath + "/img/noprofile.jpg";

	    String profileImgSrc;
	    if (profile == null || profile.getMem_img() == null || profile.getMem_img().isEmpty()) {
	        profileImgSrc = defaultImg;
	    } else {
	        
	    	profileImgSrc = "/upload/profile/" + profile.getMem_img();
	    }

	    model.addAttribute("user", user);
	    model.addAttribute("profile", profile);
	    model.addAttribute("profileImgSrc", profileImgSrc);

	    return "profile/myProfile";
	}


	// myProfile.jsp - 내 프로필 수정하기
	@Value("${file.upload.path}")
	private String uploadPath;

	@PostMapping("/profile/updateProfile.do")
	public String updateProfile(
			MemberProfileVo profileVo,
			@RequestParam(required = false) MultipartFile mem_photo,
			HttpSession session
	) throws Exception {

		MemberVo user = (MemberVo) session.getAttribute("user");
		profileVo.setMem_idx(user.getMem_idx());

		if (mem_photo != null && !mem_photo.isEmpty()) {
			File dir = new File(uploadPath);
			if (!dir.exists()) dir.mkdirs();

			String fileName = System.currentTimeMillis() + "_" + mem_photo.getOriginalFilename();
			mem_photo.transferTo(new File(uploadPath + fileName));

			profileVo.setMem_img(fileName);
		}

		MemberProfileVo exist = memberDao.selectProfileByMemIdx(user.getMem_idx());

		if (exist == null) {
			memberDao.insertProfile(profileVo);
		} else {
			memberDao.updateProfile(profileVo);
		}

		return "redirect:/profile/myProfile.do";
	}
	
	
	// 탈퇴 관련 ------------------------------------------------------------------------------------------
	
	
	// myProfile.jsp - 회원 탈퇴 기능 구현
	@PostMapping("/myDelete.do")
	public String myDelete(HttpSession session) {
	    session.invalidate();   // 전체 세션 제거
	    return "redirect:/main.do";     // 메인 홈(재웅님)
	}
	
	
	
	
	
	
	
	
}
