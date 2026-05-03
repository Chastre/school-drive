<%-- 
    Document   : processar_estado_aula
    Created on : 19/01/2026, 11:50:01
    Author     : pmnch
--%>

<%@page import="java.sql.*"%>
<%@page import="util.ConexaoBD"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Validação de sessão
    if (session.getAttribute("logado") == null || !((Boolean)session.getAttribute("logado"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String tipo = (String) session.getAttribute("tipo");
    if (!"Instrutor".equals(tipo)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Receber parâmetros
    String idAulaStr = request.getParameter("idAula");
    String novoEstado = request.getParameter("estado");
    String semanaParam = request.getParameter("semana");
    
    String redirectUrl = "minhas_aulas_instrutor.jsp";
    if (semanaParam != null) {
        redirectUrl += "?semana=" + semanaParam;
    }
    
    if (idAulaStr != null && novoEstado != null) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = ConexaoBD.getConnection();
            
            // Atualizar estado da aula
            String sql = "UPDATE aula_conducao SET estado = ? WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, novoEstado);
            pstmt.setInt(2, Integer.parseInt(idAulaStr));
            
            int linhasAfetadas = pstmt.executeUpdate();
            
            if (linhasAfetadas > 0) {
                // Sucesso - redirecionar de volta
                response.sendRedirect(redirectUrl + (redirectUrl.contains("?") ? "&" : "?") + "sucesso=1");
            } else {
                // Erro - aula não encontrada
                response.sendRedirect(redirectUrl + (redirectUrl.contains("?") ? "&" : "?") + "erro=1");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(redirectUrl + (redirectUrl.contains("?") ? "&" : "?") + "erro=2");
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    } else {
        response.sendRedirect(redirectUrl);
    }
%>
 