import 'package:flutter/material.dart';

Widget buildSearchBar( String value, Function(String) onSearchChanged) {
  return Column(
    children: [
      const SizedBox(height: 10),
      TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: const TextStyle(color: Colors.white),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: const Color(0xff283963),
        ),
      ),
    ],
  );
}