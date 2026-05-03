<%-- 
    Document   : diagnostico_aluno
    Created on : 14/01/2026, 09:07:17
    Author     : pmnch
--%>

<%@page import="java.sql.*"%>
<%@page import="util.ConexaoBD"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    // VALIDAÇÃO DE SESSÃO
    if (session.getAttribute("logado") == null || !((Boolean)session.getAttribute("logado"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    String username = (String) session.getAttribute("username");
    Integer idUtilizador = (Integer) session.getAttribute("idUtilizador");
%>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="utf-8">
    <title>Diagnóstico - Sistema</title>
    <style>
        body {
            font-family: monospace;
            background: #1a1a1a;
            color: #00ff00;
            padding: 40px;
        }
        
        .section {
            background: #2a2a2a;
            border: 2px solid #00ff00;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 30px;
        }
        
        h2 {
            color: #ffff00;
            border-bottom: 2px solid #ffff00;
            padding-bottom: 10px;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        
        th, td {
            border: 1px solid #00ff00;
            padding: 12px;
            text-align: left;
        }
        
        th {
            background: #00ff00;
            color: #1a1a1a;
            font-weight: bold;
        }
        
        .error {
            color: #ff0000;
            font-weight: bold;
        }
        
        .success {
            color: #00ff00;
            font-weight: bold;
        }
        
        .warning {
            color: #ffaa00;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <h1>🔍 DIAGNÓSTICO DO SISTEMA</h1>
    
    <!-- SESSÃO -->
    <div class="section">
        <h2>1. DADOS DA SESSÃO</h2>
        <table>
            <tr>
                <th>Atributo</th>
                <th>Valor</th>
            </tr>
            <tr>
                <td>Username</td>
                <td class="success"><%= username %></td>
            </tr>
            <tr>
                <td>ID Utilizador</td>
                <td class="success"><%= idUtilizador %></td>
            </tr>
            <tr>
                <td>Tipo</td>
                <td class="success"><%= session.getAttribute("tipo") %></td>
            </tr>
        </table>
    </div>
    
    <!-- TABELA T_UTILIZADOR -->
    <div class="section">
        <h2>2. DADOS EM t_utilizador (ID = <%= idUtilizador %>)</h2>
        <%
        Connection conn1 = null;
        PreparedStatement pstmt1 = null;
        ResultSet rs1 = null;
        
        String emailUtilizador = "";
        
        try {
            conn1 = ConexaoBD.getConnection();
            String sql1 = "SELECT * FROM t_utilizador WHERE id = ?";
            pstmt1 = conn1.prepareStatement(sql1);
            pstmt1.setInt(1, idUtilizador);
            rs1 = pstmt1.executeQuery();
            
            if (rs1.next()) {
                emailUtilizador = rs1.getString("email");
        %>
                <table>
                    <tr><th>Campo</th><th>Valor</th></tr>
                    <tr><td>ID</td><td><%= rs1.getInt("id") %></td></tr>
                    <tr><td>Username</td><td><%= rs1.getString("username") %></td></tr>
                    <tr><td>Email</td><td class="warning"><%= emailUtilizador %></td></tr>
                    <tr><td>Tipo</td><td><%= rs1.getString("tipo") %></td></tr>
                </table>
        <%
            } else {
        %>
                <p class="error">❌ UTILIZADOR NÃO ENCONTRADO!</p>
        <%
            }
        } catch (Exception e) {
        %>
            <p class="error">❌ ERRO: <%= e.getMessage() %></p>
        <%
        } finally {
            try {
                if (rs1 != null) rs1.close();
                if (pstmt1 != null) pstmt1.close();
                if (conn1 != null) conn1.close();
            } catch (SQLException e) {}
        }
        %>
    </div>
    
    <!-- TABELA ALUNO -->
    <div class="section">
        <h2>3. PROCURAR ALUNO COM EMAIL: <%= emailUtilizador %></h2>
        <%
        if (emailUtilizador.isEmpty()) {
        %>
            <p class="error">❌ Email não encontrado na t_utilizador!</p>
        <%
        } else {
            Connection conn2 = null;
            PreparedStatement pstmt2 = null;
            ResultSet rs2 = null;
            
            try {
                conn2 = ConexaoBD.getConnection();
                String sql2 = "SELECT * FROM aluno WHERE email = ?";
                pstmt2 = conn2.prepareStatement(sql2);
                pstmt2.setString(1, emailUtilizador);
                rs2 = pstmt2.executeQuery();
                
                if (rs2.next()) {
        %>
                    <p class="success">✅ ALUNO ENCONTRADO!</p>
                    <table>
                        <tr><th>Campo</th><th>Valor</th></tr>
                        <tr><td>ID</td><td class="success"><%= rs2.getInt("id") %></td></tr>
                        <tr><td>Nome</td><td><%= rs2.getString("nome") %></td></tr>
                        <tr><td>Email</td><td><%= rs2.getString("email") %></td></tr>
                        <tr><td>Telemóvel</td><td><%= rs2.getString("telemovel") %></td></tr>
                        <tr><td>Categoria</td><td><%= rs2.getString("categoria") %></td></tr>
                    </table>
        <%
                } else {
        %>
                    <p class="error">❌ ALUNO NÃO ENCONTRADO COM ESTE EMAIL!</p>
                    <p class="warning">⚠️ Isso significa que o aluno não foi criado na tabela 'aluno'</p>
        <%
                }
            } catch (Exception e) {
        %>
                <p class="error">❌ ERRO: <%= e.getMessage() %></p>
        <%
            } finally {
                try {
                    if (rs2 != null) rs2.close();
                    if (pstmt2 != null) pstmt2.close();
                    if (conn2 != null) conn2.close();
                } catch (SQLException e) {}
            }
        }
        %>
    </div>
    
    <!-- TODOS OS ALUNOS -->
    <div class="section">
        <h2>4. TODOS OS ALUNOS NA BASE DE DADOS</h2>
        <%
        Connection conn3 = null;
        PreparedStatement pstmt3 = null;
        ResultSet rs3 = null;
        
        try {
            conn3 = ConexaoBD.getConnection();
            String sql3 = "SELECT id, nome, email FROM aluno";
            pstmt3 = conn3.prepareStatement(sql3);
            rs3 = pstmt3.executeQuery();
            
            boolean temAlunos = false;
        %>
            <table>
                <tr>
                    <th>ID</th>
                    <th>Nome</th>
                    <th>Email</th>
                </tr>
        <%
            while (rs3.next()) {
                temAlunos = true;
        %>
                <tr>
                    <td><%= rs3.getInt("id") %></td>
                    <td><%= rs3.getString("nome") %></td>
                    <td><%= rs3.getString("email") %></td>
                </tr>
        <%
            }
        %>
            </table>
        <%
            if (!temAlunos) {
        %>
                <p class="error">❌ NENHUM ALUNO NA BASE DE DADOS!</p>
        <%
            }
        } catch (Exception e) {
        %>
            <p class="error">❌ ERRO: <%= e.getMessage() %></p>
        <%
        } finally {
            try {
                if (rs3 != null) rs3.close();
                if (pstmt3 != null) pstmt3.close();
                if (conn3 != null) conn3.close();
            } catch (SQLException e) {}
        }
        %>
    </div>
    
    <!-- SOLUÇÃO -->
    <div class="section">
        <h2>💡 SOLUÇÃO</h2>
        <p>Se o aluno NÃO foi encontrado, tens 2 opções:</p>
        <p><strong>OPÇÃO 1:</strong> Criar o aluno manualmente na base de dados</p>
        <p><strong>OPÇÃO 2:</strong> Corrigir o sistema de registo para criar automaticamente</p>
        <br>
        <p><a href="dashboard_aluno.jsp" style="color: #00ff00;">← Voltar ao Dashboard</a></p>
    </div>
</body>
</html>

