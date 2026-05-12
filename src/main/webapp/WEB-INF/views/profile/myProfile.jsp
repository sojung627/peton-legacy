<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>나의 프로필 | PetOn</title>
<%@ include file="/WEB-INF/views/common/head.jsp" %>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<script type="text/javascript">
// 원래 프로필 값 (취소 버튼에서 롤백용)
const originalNickname = "${profile.mem_nickname}";
const originalIntro    = "${profile.mem_intro == null ? '' : profile.mem_intro}";

// 닉네임 중복 체크
document.addEventListener("DOMContentLoaded", function () {
    const nicknameInput = document.querySelector("#nickname");
    const nicknameMsg   = document.querySelector("#nicknameMsg");
    const introTextarea = document.querySelector("#mem_intro");
    const previewImg    = document.querySelector("#preview");
    const fileInput     = document.querySelector("#fileInput");

    function checkNickname() {
        const value = nicknameInput.value.trim();
        if (value === "") {
            nicknameMsg.textContent = "";
            return;
        }

        // 기존 닉네임이면 안내만
        if (value === originalNickname) {
            nicknameMsg.style.color = "gray";
            nicknameMsg.textContent = "현재 사용 중인 닉네임입니다.";
            return;
        }

        fetch("/member/check_nickname.do?mem_nickname=" + encodeURIComponent(value))
            .then(res => res.json())
            .then(data => {
                if (data.result) {
                    nicknameMsg.style.color = "gray";
                    nicknameMsg.textContent = "✔ 사용 가능합니다.";
                } else {
                    nicknameMsg.style.color = "red";
                    nicknameMsg.textContent = "✘ 이미 사용 중입니다.";
                }
            })
            .catch(err => {
                console.error("닉네임 중복 체크 에러:", err);
                nicknameMsg.style.color = "red";
                nicknameMsg.textContent = "중복 확인 실패";
            });
    }

    // 닉네임 입력 이벤트
    if (nicknameInput) {
        nicknameInput.addEventListener("input", checkNickname);
    }

    // 취소 버튼: 원래 값으로 롤백
    const cancelBtn = document.querySelector("#btn-cancel");
    if (cancelBtn) {
        cancelBtn.addEventListener("click", function () {
            // 닉네임
            if (nicknameInput) {
                nicknameInput.value = originalNickname;
                nicknameMsg.textContent = "";
            }
            // 한 줄 소개
            if (introTextarea) {
                introTextarea.value = originalIntro;
            }
            // 프로필 이미지 (파일 선택 초기화 + 이미지 src 복구)
            if (fileInput) {
                fileInput.value = "";
            }
            if (previewImg) {
                previewImg.src = "${profileImgSrc}";
            }
        });
    }
});

// 이미지 미리보기
function previewImage(input) {
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        reader.onload = function(e) {
            $('#preview').attr('src', e.target.result);
        }
        reader.readAsDataURL(input.files[0]);
    }
}


// 최초 등록 시 -> 전부 등록해야 비활성화 해제
// 수정 시 -> 하나만 수정해도 가능
window.onload = function() {
    const nicknameIdx = document.querySelector("#nickname");
    const fileInput = document.querySelector("#fileInput");
    const introArea = document.querySelector("#mem_intro");
    const saveBtn = document.querySelector("button[name='save']");

    // 🌟 [핵심] 서버에서 받아온 기존 값이 있는지 확인 (최초 등록 여부 판단)
    // JSP EL을 사용해서 기존 값이 없으면 true, 있으면 false
    const isFirstRegistration = ("${profile.mem_nickname}" === "");

    if (isFirstRegistration) {

        // 초기 상태: 비활성화
        saveBtn.disabled = true;
        saveBtn.style.opacity = "0.5";
        saveBtn.style.cursor = "not-allowed";

        // 값이 변할 때마다 체크하는 이벤트 연결
        nicknameIdx.addEventListener("input", checkValidForFirst);
        fileInput.addEventListener("change", checkValidForFirst);
        introArea.addEventListener("input", checkValidForFirst);

        function checkValidForFirst() {
            let nickname = nicknameIdx.value.trim();
            let intro = introArea.value.trim();
            let img = fileInput.value;

            // 세 가지가 다 차야 버튼 활성화
            let isValid = (nickname !== "") && (intro !== "") && (img !== "");

            saveBtn.disabled = !isValid;
            saveBtn.style.opacity = isValid ? "1" : "0.5";
            saveBtn.style.cursor = isValid ? "pointer" : "not-allowed";
        }
    } else {
        saveBtn.disabled = false;
        saveBtn.style.opacity = "1";
        saveBtn.style.cursor = "pointer";
    }
}
</script>
</head>
<body class="bg-gray-50 layout-body">

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<main class="layout-main max-w-6xl mx-auto px-4 py-8">
  <div class="flex flex-col md:flex-row gap-8">

    <!-- 왼쪽: 마이페이지 사이드바 -->
    <aside class="w-full md:w-64 flex-shrink-0">
      <div class="bg-white rounded-3xl shadow-sm border border-gray-100 p-6 sticky top-24">
        <h2 class="text-xl font-extrabold text-gray-900 mb-6 px-2">마이페이지</h2>
        <nav class="flex flex-row md:flex-col gap-2 overflow-x-auto md:overflow-visible pb-4 md:pb-0">
          <a href="${pageContext.request.contextPath}/profile/myProfile.do"
             class="flex items-center gap-3 px-4 py-3 rounded-xl transition-all whitespace-nowrap bg-amber-50 text-amber-600 font-bold">
            <span class="text-amber-500">👤</span>
            <span class="flex-1 text-left">나의 프로필</span>
          </a>
          <a href="${pageContext.request.contextPath}/profile/petProfile_form.do"
             class="flex items-center gap-3 px-4 py-3 rounded-xl transition-all whitespace-nowrap text-gray-500 hover:bg-gray-50 font-medium">
            <span class="text-gray-400">💗</span>
            <span class="flex-1 text-left">마이펫</span>
          </a>
          <a href="${pageContext.request.contextPath}/orders/list"
             class="flex items-center gap-3 px-4 py-3 rounded-xl transition-all whitespace-nowrap text-gray-500 hover:bg-gray-50 font-medium">
            <span class="text-gray-400">📦</span>
            <span class="flex-1 text-left">나의 주문</span>
          </a>
          <a href="${pageContext.request.contextPath}/update/myUpdate_form.do"
             class="flex items-center gap-3 px-4 py-3 rounded-xl transition-all whitespace-nowrap text-gray-500 hover:bg-gray-50 font-medium">
            <span class="text-gray-400">⚙️</span>
            <span class="flex-1 text-left">회원정보수정</span>
          </a>
        </nav>
      </div>
    </aside>

    <!-- 오른쪽: 나의 프로필 메인 (폭 고정 + 중앙 정렬) -->
    <section class="flex-1 min-w-0 flex justify-center">
      <div class="w-full max-w-4xl">
        <form class="myUpdate bg-white rounded-3xl shadow-sm border border-gray-100 p-8"
              action="${pageContext.request.contextPath}/profile/updateProfile.do"
              method="post"
              enctype="multipart/form-data">

          <h2 class="text-2xl font-bold text-gray-900 mb-8 pb-4 border-b border-gray-100">
            나의 프로필
          </h2>

          <!-- 숨겨진 값들 -->
          <input type="hidden" id="mem_idx"  name="mem_idx"  value="${user.mem_idx}">
          <input type="hidden" id="mem_id"   name="mem_id"   value="${user.mem_id}">

          <div class="flex flex-col md:flex-row gap-12">
            <!-- Profile Image Section -->
            <div class="flex flex-col items-center gap-4">
              <div class="relative group">
                <div class="w-32 h-32 rounded-full overflow-hidden border-4 border-amber-50 shadow-inner">
                  <img 
                    id="preview"
                    img src="${profileImgSrc}"
                    alt="Profile"
                    class="w-full h-full object-cover"
                  />
                </div>
                <button type="button"
                        onclick="document.getElementById('fileInput').click();"
                        class="absolute bottom-0 right-0 p-2 bg-white rounded-full shadow-md border border-gray-200 text-gray-500 hover:text-amber-500 hover:border-amber-400 transition-colors">
                  📷
                </button>
              </div>
              <button type="button"
                      onclick="document.getElementById('fileInput').click();"
                      class="text-sm font-bold text-gray-500 hover:text-amber-500 underline decoration-gray-300 hover:decoration-amber-500 underline-offset-4 transition-all">
                이미지 변경
              </button> 
              <input type="file"
                     name="mem_photo"   
                     id="fileInput"
                     onchange="previewImage(this)"
                     style="display:none;">
            </div>

            <!-- Form Section -->
            <div class="flex-1 flex flex-col gap-6">
              <!-- 닉네임 -->
              <div>
                <label class="block text-sm font-bold text-gray-700 mb-2">
                  닉네임 <span class="text-red-500">*</span>
                </label>
                <input 
                  type="text" 
                  id="nickname"
                  name="mem_nickname"
                  value="${profile.mem_nickname}"
                  class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent transition-all font-medium text-gray-900"
                  placeholder="닉네임을 입력해주세요"
                  maxlength="10"
                />
                <p class="mt-1 text-xs text-gray-400">
                  * 한글, 영문, 숫자 포함 2~10자 이내로 입력해주세요.
                </p>
                <span id="nicknameMsg" class="mt-1 text-xs"></span>
              </div>

              <!-- 한 줄 소개 -->
              <div>
                <label class="block text-sm font-bold text-gray-700 mb-2">
                  한 줄 소개
                </label>
                <textarea 
                  id="mem_intro"
                  name="mem_intro"
                  rows="4"
                  class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent transition-all font-medium text-gray-700 h-32 resize-none"
                  placeholder="자신을 자유롭게 소개해보세요!"
                  maxlength="100"
                >${profile.mem_intro}</textarea>
                <div class="flex justify-end mt-2">
                  <span class="text-xs text-gray-400">
           
                  </span>
                </div>
              </div>
            </div>
          </div>

          <!-- Actions -->
          <div class="flex justify-end items-center gap-3 mt-12 pt-6 border-t border-gray-100">
            <button type="button"
                    id="btn-cancel"
                    class="px-6 py-3 rounded-xl border-2 border-gray-200 text-gray-600 font-bold hover:bg-gray-50 transition-colors"
                    onclick="location.href='${pageContext.request.contextPath}/main'">
              취소
            </button>
            <button type="submit"  name="save"
                    class="px-6 py-3 rounded-xl bg-amber-400 text-white font-bold hover:bg-amber-500 shadow-md transition-all flex items-center gap-2"
                    disabled >
              💾 변경사항 저장
            </button>
          </div>

        </form>
      </div>
    </section>

  </div>
</main>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
<script src="${pageContext.request.contextPath}/resources/js/main.js"></script>
</body>
</html>
