<%-- 
    Document   : processar_registo
    Created on : 26/01/2026, 09:24:33
    Author     : pmnch
--%>

<%@page import="java.sql.*"%>
<%@page import="util.ConexaoBD"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String username    = request.getParameter("username");
    String password    = request.getParameter("password");
    String email       = request.getParameter("email");
    String nome        = request.getParameter("nome");
    String telemovel   = request.getParameter("telemovel");
    String dataNasc    = request.getParameter("dataNascimento");
    String categoria   = request.getParameter("categoria");
    String morada      = request.getParameter("morada");

    // Validar campos obrigatórios
    if (username==null||password==null||email==null||nome==null||telemovel==null||dataNasc==null||categoria==null||morada==null||
        username.trim().isEmpty()||password.trim().isEmpty()||email.trim().isEmpty()||nome.trim().isEmpty()||
        telemovel.trim().isEmpty()||dataNasc.trim().isEmpty()||categoria.trim().isEmpty()||morada.trim().isEmpty()) {
        response.sendRedirect("registo.jsp?erro=campos");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        conn = ConexaoBD.getConnection();
        conn.setAutoCommit(false);

        // PASSO 1: Criar utilizador
        pstmt = conn.prepareStatement("INSERT INTO t_utilizador (username, password, email, tipo) VALUES (?, ?, ?, 'Aluno')");
        pstmt.setString(1, username.trim());
        pstmt.setString(2, password.trim());
        pstmt.setString(3, email.trim());
        pstmt.executeUpdate();
        pstmt.close();

        // PASSO 2: Escolher instrutor com menos alunos
        int idInstrutorEscolhido = 1;
        pstmt = conn.prepareStatement(
            "SELECT i.id FROM instrutor i " +
            "LEFT JOIN aluno a ON a.idInstrutor = i.id " +
            "WHERE i.ativo = 1 " +
            "GROUP BY i.id " +
            "ORDER BY COUNT(a.id) ASC LIMIT 1");
        ResultSet rs = pstmt.executeQuery();
        if (rs.next()) idInstrutorEscolhido = rs.getInt("id");
        rs.close(); pstmt.close();

        // PASSO 3: Criar perfil de aluno com todos os dados
        pstmt = conn.prepareStatement(
            "INSERT INTO aluno (nome, email, telemovel, dataNascimento, categoria, morada, idInstrutor) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?)");
        pstmt.setString(1, nome.trim());
        pstmt.setString(2, email.trim());
        pstmt.setString(3, telemovel.trim());
        pstmt.setString(4, dataNasc);
        pstmt.setString(5, categoria.trim());
        pstmt.setString(6, morada.trim());
        pstmt.setInt(7, idInstrutorEscolhido);
        pstmt.executeUpdate();
        pstmt.close();

        conn.commit();
        response.sendRedirect("login.jsp?sucesso=1");

    } catch (SQLException e) {
        if (conn != null) { try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); } }
        if (e.getMessage() != null && (e.getMessage().contains("Duplicate") || e.getMessage().contains("duplicate"))) {
            response.sendRedirect("registo.jsp?erro=duplicado");
        } else {
            e.printStackTrace();
            response.sendRedirect("registo.jsp?erro=bd");
        }
    } finally {
        try {
            if (pstmt != null) pstmt.close();
            if (conn != null) { conn.setAutoCommit(true); conn.close(); }
        } catch (SQLException e) { e.printStackTrace(); }
    }
%>
