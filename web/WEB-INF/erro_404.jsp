<%@page contentType="text/html" pageEncoding="UTF-8" isErrorPage="true"%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Página não encontrada - Drive School</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Work+Sans:wght@400;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Work Sans',sans-serif; background:linear-gradient(135deg,#1a3a4d 0%,#800020 100%); min-height:100vh; display:flex; align-items:center; justify-content:center; color:white; }
        .card { text-align:center; padding:60px 40px; max-width:500px; }
        .icone { font-size:6rem; color:rgba(255,193,7,.4); margin-bottom:24px; }
        .codigo { font-size:7rem; font-weight:800; color:#FFC107; line-height:1; margin-bottom:10px; text-shadow:0 0 40px rgba(255,193,7,.3); }
        h1 { font-size:1.6rem; font-weight:700; margin-bottom:12px; }
        p { color:rgba(255,255,255,.6); font-size:.95rem; line-height:1.7; margin-bottom:32px; }
        .btns { display:flex; gap:14px; justify-content:center; flex-wrap:wrap; }
        .btn { padding:12px 28px; border-radius:25px; font-weight:700; text-decoration:none; font-size:.9rem; display:inline-flex; align-items:center; gap:8px; transition:all .3s; }
        .btn-primary { background:linear-gradient(135deg,#FFC107,#FFB300); color:#1a3a4d; }
        .btn-primary:hover { transform:translateY(-2px); box-shadow:0 8px 25px rgba(255,193,7,.4); }
        .btn-secondary { background:rgba(255,255,255,.1); color:white; border:2px solid rgba(255,255,255,.3); }
        .btn-secondary:hover { border-color:#FFC107; color:#FFC107; }
    </style>
</head>
<body>
    <div class="card">
        <div class="icone"><i class="fa fa-map-signs"></i></div>
        <div class="codigo">404</div>
        <h1>Página não encontrada</h1>
        <p>A página que procuras não existe ou foi movida.<br>Verifica o endereço ou volta ao início.</p>
        <div class="btns">
            <a href="index.jsp" class="btn btn-primary"><i class="fa fa-home"></i>Página Inicial</a>
            <a href="javascript:history.back()" class="btn btn-secondary"><i class="fa fa-arrow-left"></i>Voltar</a>
        </div>
    </div>
</body>
</html>
