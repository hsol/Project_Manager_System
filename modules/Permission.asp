<%
	If IsEmpty(ROLE) Then
	    ROLE = "all"
	End If

	If ROLE = "admin" Then
		If User.data("isLogin") = "false" Then
			AlertGo "로그인 해주세요.", "/"
		Else
			If User.data("userClass") <> "admin" Then
				AlertGo "관리자로 로그인 해주세요.", "/"
			End If
		End If
	ElseIf ROLE = "user" Then
		If User.data("isLogin") = "false" Then
			AlertGo "로그인 해주세요.", "/"
		End If
	Else
	End If

	DBHelper.Dispose
	Set DBHelper = Nothing
%>