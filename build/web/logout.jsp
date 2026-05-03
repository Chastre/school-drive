<%-- 
    Document   : logout
    Created on : 18/12/2025, 00:15:16
    Author     : pmnch
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    session.invalidate();
    response.sendRedirect("index.jsp");
%>

