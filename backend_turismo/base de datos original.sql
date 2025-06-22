--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.4

-- Started on 2025-06-19 23:55:39

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5189 (class 0 OID 41560)
-- Dependencies: 228
-- Data for Name: alojamiento_servicios; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5187 (class 0 OID 41514)
-- Dependencies: 226
-- Data for Name: alojamientos; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5183 (class 0 OID 41494)
-- Dependencies: 222
-- Data for Name: categorias_alojamiento; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.categorias_alojamiento (id, nombre, descripcion, icono, activo) VALUES (1, 'Casa Rural', 'Casa completa en comunidad rural con vista al lago', NULL, true);
INSERT INTO public.categorias_alojamiento (id, nombre, descripcion, icono, activo) VALUES (2, 'Habitación Familiar', 'Habitación en casa de familia local', NULL, true);
INSERT INTO public.categorias_alojamiento (id, nombre, descripcion, icono, activo) VALUES (3, 'Cabaña Ecológica', 'Cabaña construida con materiales locales', NULL, true);
INSERT INTO public.categorias_alojamiento (id, nombre, descripcion, icono, activo) VALUES (4, 'Casa Flotante', 'Alojamiento sobre el agua del Lago Titicaca', NULL, true);
INSERT INTO public.categorias_alojamiento (id, nombre, descripcion, icono, activo) VALUES (5, 'Hospedaje Comunitario', 'Alojamiento gestionado por la comunidad', NULL, true);
INSERT INTO public.categorias_alojamiento (id, nombre, descripcion, icono, activo) VALUES (6, 'Casa de Adobe', 'Casa tradicional construida con adobe', NULL, true);
INSERT INTO public.categorias_alojamiento (id, nombre, descripcion, icono, activo) VALUES (7, 'Mirador', 'Alojamiento con vista panorámica al lago', NULL, true);


--
-- TOC entry 5181 (class 0 OID 41474)
-- Dependencies: 220
-- Data for Name: direcciones; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5193 (class 0 OID 41598)
-- Dependencies: 232
-- Data for Name: disponibilidad; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5210 (class 0 OID 42048)
-- Dependencies: 249
-- Data for Name: emprendedor; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5215 (class 0 OID 42363)
-- Dependencies: 254
-- Data for Name: emprendedores; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5203 (class 0 OID 41743)
-- Dependencies: 242
-- Data for Name: experiencias; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5207 (class 0 OID 41786)
-- Dependencies: 246
-- Data for Name: favoritos; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5191 (class 0 OID 41580)
-- Dependencies: 230
-- Data for Name: fotos_alojamiento; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5201 (class 0 OID 41714)
-- Dependencies: 240
-- Data for Name: mensajes; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5197 (class 0 OID 41656)
-- Dependencies: 236
-- Data for Name: pagos; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5209 (class 0 OID 41815)
-- Dependencies: 248
-- Data for Name: reportes; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5199 (class 0 OID 41678)
-- Dependencies: 238
-- Data for Name: resenas; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5211 (class 0 OID 42225)
-- Dependencies: 250
-- Data for Name: reserva; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5195 (class 0 OID 41617)
-- Dependencies: 234
-- Data for Name: reservas; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5205 (class 0 OID 41763)
-- Dependencies: 244
-- Data for Name: reservas_experiencias; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5185 (class 0 OID 41504)
-- Dependencies: 224
-- Data for Name: servicios; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.servicios (id, nombre, descripcion, icono, categoria, activo) VALUES (1, 'WiFi', NULL, NULL, 'basico', true);
INSERT INTO public.servicios (id, nombre, descripcion, icono, categoria, activo) VALUES (2, 'Agua caliente', NULL, NULL, 'basico', true);
INSERT INTO public.servicios (id, nombre, descripcion, icono, categoria, activo) VALUES (3, 'Electricidad', NULL, NULL, 'basico', true);
INSERT INTO public.servicios (id, nombre, descripcion, icono, categoria, activo) VALUES (4, 'Ropa de cama', NULL, NULL, 'basico', true);
INSERT INTO public.servicios (id, nombre, descripcion, icono, categoria, activo) VALUES (5, 'Toallas', NULL, NULL, 'basico', true);
INSERT INTO public.servicios (id, nombre, descripcion, icono, categoria, activo) VALUES (6, 'Cocina', NULL, NULL, 'basico', true);
INSERT INTO public.servicios (id, nombre, descripcion, icono, categoria, activo) VALUES (7, 'Baño privado', NULL, NULL, 'basico', true);
INSERT INTO public.servicios (id, nombre, descripcion, icono, categoria, activo) VALUES (8, 'Vista al lago', NULL, NULL, 'entretenimiento', true);
INSERT INTO public.servicios (id, nombre, descripcion, icono, categoria, activo) VALUES (9, 'Kayak', NULL, NULL, 'entretenimiento', true);
INSERT INTO public.servicios (id, nombre, descripcion, icono, categoria, activo) VALUES (10, 'Bote', NULL, NULL, 'entretenimiento', true);
INSERT INTO public.servicios (id, nombre, descripcion, icono, categoria, activo) VALUES (11, 'Fogata', NULL, NULL, 'entretenimiento', true);
INSERT INTO public.servicios (id, nombre, descripcion, icono, categoria, activo) VALUES (12, 'Zona de parrilla', NULL, NULL, 'entretenimiento', true);
INSERT INTO public.servicios (id, nombre, descripcion, icono, categoria, activo) VALUES (13, 'Huerto orgánico', NULL, NULL, 'entretenimiento', true);
INSERT INTO public.servicios (id, nombre, descripcion, icono, categoria, activo) VALUES (14, 'Pesca', NULL, NULL, 'entretenimiento', true);
INSERT INTO public.servicios (id, nombre, descripcion, icono, categoria, activo) VALUES (15, 'Cuna disponible', NULL, NULL, 'familiar', true);
INSERT INTO public.servicios (id, nombre, descripcion, icono, categoria, activo) VALUES (16, 'Juegos para niños', NULL, NULL, 'familiar', true);
INSERT INTO public.servicios (id, nombre, descripcion, icono, categoria, activo) VALUES (17, 'Área de juegos', NULL, NULL, 'familiar', true);
INSERT INTO public.servicios (id, nombre, descripcion, icono, categoria, activo) VALUES (18, 'Comidas incluidas', NULL, NULL, 'familiar', true);
INSERT INTO public.servicios (id, nombre, descripcion, icono, categoria, activo) VALUES (19, 'Clases de quechua', NULL, NULL, 'cultural', true);
INSERT INTO public.servicios (id, nombre, descripcion, icono, categoria, activo) VALUES (20, 'Cocina tradicional', NULL, NULL, 'cultural', true);
INSERT INTO public.servicios (id, nombre, descripcion, icono, categoria, activo) VALUES (21, 'Textilería andina', NULL, NULL, 'cultural', true);
INSERT INTO public.servicios (id, nombre, descripcion, icono, categoria, activo) VALUES (22, 'Música folklórica', NULL, NULL, 'cultural', true);
INSERT INTO public.servicios (id, nombre, descripcion, icono, categoria, activo) VALUES (23, 'Ceremonias ancestrales', NULL, NULL, 'cultural', true);


--
-- TOC entry 5213 (class 0 OID 42267)
-- Dependencies: 252
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5179 (class 0 OID 41457)
-- Dependencies: 218
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.usuarios (id, email, nombre, apellidos, telefono, fecha_nacimiento, genero, dni, foto_perfil, idiomas, descripcion, es_anfitrion, verificado, fecha_registro, fecha_verificacion, activo, rol, password) VALUES (9, 'emprendedor@ejemplo.com', 'Juan', 'Perez', NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, false, '2025-06-18 16:35:22.579737', NULL, true, 'ADMIN', NULL);
INSERT INTO public.usuarios (id, email, nombre, apellidos, telefono, fecha_nacimiento, genero, dni, foto_perfil, idiomas, descripcion, es_anfitrion, verificado, fecha_registro, fecha_verificacion, activo, rol, password) VALUES (10, 'admin@ejemplo.com', 'Admin', 'Demo', NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, false, '2025-06-18 17:05:08.44626', NULL, true, 'ADMIN', NULL);
INSERT INTO public.usuarios (id, email, nombre, apellidos, telefono, fecha_nacimiento, genero, dni, foto_perfil, idiomas, descripcion, es_anfitrion, verificado, fecha_registro, fecha_verificacion, activo, rol, password) VALUES (11, 'usuario1@ejemplo.com', 'Juan', 'Perez', NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, false, '2025-06-18 17:39:07.965919', NULL, true, 'USER', '$2a$10$x9BUvbLxWGXgH7lwb3eHiuVkEj3oHR0jDQoIdbkitKexFa3tosL4S');
INSERT INTO public.usuarios (id, email, nombre, apellidos, telefono, fecha_nacimiento, genero, dni, foto_perfil, idiomas, descripcion, es_anfitrion, verificado, fecha_registro, fecha_verificacion, activo, rol, password) VALUES (12, 'usuario2@ejemplo.com', 'Juan', 'Perez', NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, false, '2025-06-18 17:45:02.571952', NULL, true, 'ADMN', '$2a$10$E2ZiDUs4S3HRB.BeMuOw0.jfa7e2hzE0X0A5kbIsP5krua08qV8dy');
INSERT INTO public.usuarios (id, email, nombre, apellidos, telefono, fecha_nacimiento, genero, dni, foto_perfil, idiomas, descripcion, es_anfitrion, verificado, fecha_registro, fecha_verificacion, activo, rol, password) VALUES (13, 'usuario3@ejemplo.com', 'pedro', 'Perez', NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, false, '2025-06-18 17:50:21.97826', NULL, true, 'ADMN', '$2a$10$.0SH519wtZ24fSp0Dxz2lupowFtgcTviFEn49VkbSpWThxNpA6FX6');
INSERT INTO public.usuarios (id, email, nombre, apellidos, telefono, fecha_nacimiento, genero, dni, foto_perfil, idiomas, descripcion, es_anfitrion, verificado, fecha_registro, fecha_verificacion, activo, rol, password) VALUES (14, 'admin1@ejemplo.com', 'Admin', 'Ejemplo', NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, false, '2025-06-18 17:55:39.080824', NULL, true, 'ADMIN', '$2a$10$g9uqi6E9BzEFfYQ6Ugw3juHDOu0qzcywg6FmmckoLhf7Fyq28SZ9y');


--
-- TOC entry 5238 (class 0 OID 0)
-- Dependencies: 227
-- Name: alojamiento_servicios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.alojamiento_servicios_id_seq', 1, false);


--
-- TOC entry 5239 (class 0 OID 0)
-- Dependencies: 225
-- Name: alojamientos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.alojamientos_id_seq', 1, false);


--
-- TOC entry 5240 (class 0 OID 0)
-- Dependencies: 221
-- Name: categorias_alojamiento_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categorias_alojamiento_id_seq', 7, true);


--
-- TOC entry 5241 (class 0 OID 0)
-- Dependencies: 219
-- Name: direcciones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.direcciones_id_seq', 1, false);


--
-- TOC entry 5242 (class 0 OID 0)
-- Dependencies: 231
-- Name: disponibilidad_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.disponibilidad_id_seq', 1, false);


--
-- TOC entry 5243 (class 0 OID 0)
-- Dependencies: 253
-- Name: emprendedores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.emprendedores_id_seq', 1, false);


--
-- TOC entry 5244 (class 0 OID 0)
-- Dependencies: 241
-- Name: experiencias_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.experiencias_id_seq', 1, false);


--
-- TOC entry 5245 (class 0 OID 0)
-- Dependencies: 245
-- Name: favoritos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.favoritos_id_seq', 1, false);


--
-- TOC entry 5246 (class 0 OID 0)
-- Dependencies: 229
-- Name: fotos_alojamiento_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fotos_alojamiento_id_seq', 1, false);


--
-- TOC entry 5247 (class 0 OID 0)
-- Dependencies: 239
-- Name: mensajes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mensajes_id_seq', 1, false);


--
-- TOC entry 5248 (class 0 OID 0)
-- Dependencies: 235
-- Name: pagos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pagos_id_seq', 1, false);


--
-- TOC entry 5249 (class 0 OID 0)
-- Dependencies: 247
-- Name: reportes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reportes_id_seq', 1, false);


--
-- TOC entry 5250 (class 0 OID 0)
-- Dependencies: 237
-- Name: resenas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.resenas_id_seq', 1, false);


--
-- TOC entry 5251 (class 0 OID 0)
-- Dependencies: 243
-- Name: reservas_experiencias_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reservas_experiencias_id_seq', 1, false);


--
-- TOC entry 5252 (class 0 OID 0)
-- Dependencies: 233
-- Name: reservas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reservas_id_seq', 1, false);


--
-- TOC entry 5253 (class 0 OID 0)
-- Dependencies: 223
-- Name: servicios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.servicios_id_seq', 23, true);


--
-- TOC entry 5254 (class 0 OID 0)
-- Dependencies: 251
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 1, false);


--
-- TOC entry 5255 (class 0 OID 0)
-- Dependencies: 217
-- Name: usuarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuarios_id_seq', 14, true);


-- Completed on 2025-06-19 23:55:39

--
-- PostgreSQL database dump complete
--

