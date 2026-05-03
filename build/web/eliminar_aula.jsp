<%-- 
    Document   : eliminar_aula
    Created on : 18/12/2025, 00:04:36
    Author     : pmnch
--%>

<%@page import="java.sql.*"%>
<%@page import="util.ConexaoBD"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    if (session.getAttribute("logado") == null || !((Boolean)session.getAttribute("logado"))) {
        response.sendRedirect("login.jsp"); return;
    }
    String username = (String) session.getAttribute("username");

    String idParam = request.getParameter("id");
    if (idParam == null || idParam.isEmpty()) {
        response.sendRedirect("listar_aulas.jsp?msg=error"); return;
    }
    int id = Integer.parseInt(idParam);

    // Se confirmado, apagar
    if ("sim".equals(request.getParameter("confirmar"))) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = ConexaoBD.getConnection();
            pstmt = conn.prepareStatement("DELETE FROM aula_conducao WHERE id = ?");
            pstmt.setInt(1, id);
            int resultado = pstmt.executeUpdate();
            if (resultado > 0) { response.sendRedirect("listar_aulas.jsp?msg=success"); }
            else { response.sendRedirect("listar_aulas.jsp?msg=error"); }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("listar_aulas.jsp?msg=error");
        } finally {
            try { if (pstmt != null) pstmt.close(); if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
        return;
    }
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Eliminar Aula - Escola de Condução</title>
    <link href="https://fonts.googleapis.com/css2?family=Work+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #1a0a2e 0%, #2d1b4e 30%, #4a0e2d 70%, #1a0a2e 100%); min-height: 100vh; }
        .topbar { background: rgba(0,0,0,0.4); backdrop-filter: blur(10px); padding: 14px 30px; border-bottom: 1px solid rgba(255,193,7,0.2); display: flex; justify-content: space-between; align-items: center; }
        .topbar-left { display: flex; align-items: center; gap: 15px; }
        .topbar-left img { height: 44px; filter: drop-shadow(0 0 8px rgba(255,193,7,0.3)); }
        .user-info { display: flex; align-items: center; gap: 8px; color: rgba(255,255,255,0.85); }
        .user-info i { color: #FFC107; }
        .btn-sair { background: rgba(128,0,32,0.8); color: white; padding: 9px 22px; border-radius: 10px; text-decoration: none; font-weight: 600; border: 1px solid rgba(255,193,7,0.3); display: inline-flex; align-items: center; gap: 8px; transition: all 0.3s; }
        .btn-sair:hover { background: #800020; transform: translateY(-2px); }
        /* OVERLAY */
        .overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.7); display: flex; align-items: center; justify-content: center; z-index: 999; }
        /* MODAL */
        .modal { background: linear-gradient(135deg, #1e0d35, #3a1040); border: 1px solid rgba(255,193,7,0.3); border-radius: 20px; padding: 45px 40px; max-width: 460px; width: 90%; text-align: center; box-shadow: 0 25px 70px rgba(0,0,0,0.6); animation: popIn 0.25s ease; }
        @keyframes popIn { from { transform: scale(0.85); opacity: 0; } to { transform: scale(1); opacity: 1; } }
        .modal-icon { width: 75px; height: 75px; background: linear-gradient(135deg, #dc3545, #a71d2a); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 20px; box-shadow: 0 8px 25px rgba(220,53,69,0.4); }
        .modal-icon i { font-size: 1.8rem; color: white; }
        .modal h2 { color: white; font-size: 1.5rem; font-weight: 800; margin-bottom: 12px; }
        .modal p { color: rgba(255,255,255,0.65); font-size: 1rem; line-height: 1.6; margin-bottom: 8px; }
        .modal .id-badge { display: inline-block; background: rgba(255,193,7,0.15); border: 1px solid rgba(255,193,7,0.3); color: #FFC107; padding: 4px 14px; border-radius: 20px; font-size: 0.85rem; font-weight: 600; margin-bottom: 30px; }
        .modal-warning { background: rgba(220,53,69,0.1); border: 1px solid rgba(220,53,69,0.3); border-radius: 10px; padding: 12px 16px; margin-bottom: 28px; color: rgba(255,180,180,0.9); font-size: 0.88rem; }
        .modal-warning i { color: #dc3545; margin-right: 6px; }
        .btn-group { display: flex; gap: 15px; justify-content: center; }
        .btn { padding: 13px 30px; border: none; border-radius: 25px; font-size: 1rem; font-weight: 700; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; transition: all 0.3s; }
        .btn-danger { background: linear-gradient(135deg, #dc3545, #a71d2a); color: white; }
        .btn-danger:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(220,53,69,0.45); }
        .btn-secondary { background: transparent; color: white; border: 2px solid rgba(255,255,255,0.3); }
        .btn-secondary:hover { border-color: #FFC107; color: #FFC107; }
    </style>
</head>
<body>
    <div class="topbar">
        <div class="topbar-left">
            <a href="dashboard.jsp"><img src="image/logo_mini.png" alt="Drive School"></a>
            <div class="user-info"><i class="fa fa-user-shield"></i><span><strong><%= username %></strong> (Admin)</span></div>
        </div>
        <a href="logout.jsp" class="btn-sair"><i class="fa fa-sign-out-alt"></i> Sair</a>
    </div>

    <div class="overlay">
        <div class="modal">
            <div class="modal-icon">
                <i class="fa fa-calendar-times"></i>
            </div>
            <h2>Eliminar Aula</h2>
            <p>Tens a certeza que queres eliminar esta aula de condução?</p>
            <div class="id-badge">ID: <%= id %></div>
            <div class="modal-warning">
                <i class="fa fa-exclamation-triangle"></i>
                Esta ação é <strong>irreversível</strong> e não pode ser desfeita!
            </div>
            <div class="btn-group">
                <a href="listar_aulas.jsp" class="btn btn-secondary">
                    <i class="fa fa-times"></i> Cancelar
                </a>
                <a href="eliminar_aula.jsp?id=<%= id %>&confirmar=sim" class="btn btn-danger">
                    <i class="fa fa-trash-alt"></i> Sim, Eliminar
                </a>
            </div>
        </div>
    </div>
</body>
</html>
