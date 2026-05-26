% ====================================
% HECHOS DINAMICOS
% ====================================

% Aqui se almacenan las respuestas del usuario
:- dynamic respuesta/2.


% ====================================
% REGLAS PRINCIPALES DEL SISTEMA
% ====================================

% Regla para iniciar el sistema
inicio :-
    limpiar,
    menu.


% ====================================
% MENU PRINCIPAL
% ====================================

menu :-
    nl,
    write('===================================='), nl,
    write(' ASISTENTE DE CUMPLIMIENTO RGPD '), nl,
    write('===================================='), nl,
    write('1. Evaluar empresa'), nl,
    write('2. Ver informacion'), nl,
    write('3. Salir'), nl,
    write('Seleccione una opcion: '),
    read(Opcion),
    opcion(Opcion).


% ====================================
% REGLAS DE OPCIONES DEL MENU
% ====================================

opcion(1) :-
    evaluar.

opcion(2) :-
    informacion.

opcion(3) :-
    write('Saliendo del sistema...'), nl.

opcion(_) :-
    write('Opcion invalida'), nl,
    menu.


% ====================================
% INFORMACION DEL SISTEMA
% ====================================

informacion :-
    nl,
    write('Este sistema evalua si una empresa'), nl,
    write('cumple con normas basicas de'), nl,
    write('proteccion de datos personales.'), nl,
    nl,
    menu.


% ====================================
% LIMPIAR HECHOS GUARDADOS
% ====================================

limpiar :-
    retractall(respuesta(_, _)).


% ====================================
% REGLA PARA HACER PREGUNTAS
% ====================================

preguntar(Pregunta) :-
    write(Pregunta),
    write(' (si/no): '),
    read(Respuesta),
    nl,

    % Aqui se crean los HECHOS
    assert(respuesta(Pregunta, Respuesta)).


% ====================================
% REGLA DE EVALUACION
% ====================================

evaluar :-
    limpiar,

    preguntar('La empresa solicita consentimiento para usar datos'),
    preguntar('El sitio tiene aviso de privacidad'),
    preguntar('Los usuarios pueden eliminar sus datos'),
    preguntar('La empresa protege datos con contrasenas o cifrado'),
    preguntar('El sitio informa sobre uso de cookies'),

    diagnostico.


% ====================================
% REGLAS DE RECOMENDACIONES
% ====================================

recomendaciones :-

    nl,
    write('RECOMENDACIONES:'), nl,

    (
        respuesta('El sitio tiene aviso de privacidad', no)
        ->
        write('- Agregar aviso de privacidad'), nl
        ;
        true
    ),

    (
        respuesta('Los usuarios pueden eliminar sus datos', no)
        ->
        write('- Permitir eliminacion de datos'), nl
        ;
        true
    ),

    (
        respuesta('La empresa protege datos con contrasenas o cifrado', no)
        ->
        write('- Implementar medidas de seguridad'), nl
        ;
        true
    ),

    (
        respuesta('El sitio informa sobre uso de cookies', no)
        ->
        write('- Mostrar aviso de cookies'), nl
        ;
        true
    ).


% ====================================
% REGLAS DEL SISTEMA EXPERTO
% ====================================

% Regla: Cumple completamente con RGPD
diagnostico :-

    respuesta('La empresa solicita consentimiento para usar datos', si),
    respuesta('El sitio tiene aviso de privacidad', si),
    respuesta('Los usuarios pueden eliminar sus datos', si),
    respuesta('La empresa protege datos con contrasenas o cifrado', si),
    respuesta('El sitio informa sobre uso de cookies', si),

    nl,
    write('===================================='), nl,
    write('RESULTADO: CUMPLE CON RGPD'), nl,
    write('La empresa cumple con los requisitos basicos.'), nl,
    write('===================================='), nl,
    menu.


% Regla: No cumple con RGPD
diagnostico :-

    respuesta('La empresa solicita consentimiento para usar datos', no),

    nl,
    write('===================================='), nl,
    write('RESULTADO: NO CUMPLE'), nl,
    write('Falta consentimiento del usuario.'), nl,
    write('===================================='), nl,
    recomendaciones,
    menu.


% Regla: Cumplimiento parcial
diagnostico :-

    nl,
    write('===================================='), nl,
    write('RESULTADO: CUMPLIMIENTO PARCIAL'), nl,
    write('La empresa necesita mejorar algunas areas.'), nl,
    write('===================================='), nl,
    recomendaciones,
    menu.