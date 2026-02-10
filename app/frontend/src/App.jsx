import React, { useState, useEffect } from 'react';

const API_URL = import.meta.env.VITE_API_BASE_URL+'/todos';

function App() {
  const [todos, setTodos] = useState([]);
  const [newTodo, setNewTodo] = useState('');
  const [loading, setLoading] = useState(false);
  const [editingId, setEditingId] = useState(null); 
  const [editText, setEditText] = useState('');    

  const fetchTodos = async () => {
    setLoading(true);
    try {
      const response = await fetch(API_URL);
      const data = await response.json();
      setTodos(Array.isArray(data) ? data : []);
    } catch (error) {
      console.error("Error cargando tareas:", error);
    }
    setLoading(false);
  };

  useEffect(() => {
    fetchTodos();
  }, []);

  const addTodo = async (e) => {
    e.preventDefault();
    if (!newTodo.trim()) return;

    const todoObj = {
      id: Date.now().toString(),
      todo: newTodo,
      status: "pendiente"
    };

    try {
      await fetch(API_URL, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(todoObj),
      });
      setNewTodo('');
      fetchTodos(); 
    } catch (error) {
      console.error("Error al crear:", error);
    }
  };

  const toggleStatus = async (item) => {
    const nuevoEstado = item.status === 'hecho' ? 'pendiente' : 'hecho';
    const updatedTodo = { ...item, status: nuevoEstado };

    try {
      await fetch(`${API_URL}/${encodeURIComponent(item.id)}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updatedTodo),
      });
      fetchTodos();
    } catch (error) {
      console.error("Error al actualizar el estado:", error);
    }
  };

  const deleteTodo = async (id) => {
    try {
      await fetch(`${API_URL}/${encodeURIComponent(id)}`, {
        method: 'DELETE',
      });
      fetchTodos();
    } catch (error) {
      console.error("Error al eliminar:", error);
    }
  };

  const updateTodoName = async (item) => {
    if (!editText.trim()) return;
    const updatedTodo = { ...item, todo: editText };

    try {
      await fetch(`${API_URL}/${encodeURIComponent(item.id)}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updatedTodo),
      });
      setEditingId(null);
      fetchTodos();
    } catch (error) {
      console.error("Error al actualizar nombre:", error);
    }
  };

  return (
    <div style={{ padding: '40px', fontFamily: 'sans-serif', backgroundColor: '#0f172a', color: 'white', minHeight: '100vh' }}>
      <h1>TO DO LIST (AWS API)</h1>
      
      <form onSubmit={addTodo} style={{ marginBottom: '20px' }}>
        <input
          type="text"
          value={newTodo}
          onChange={(e) => setNewTodo(e.target.value)}
          placeholder="Escribe una tarea..."
          style={{ padding: '10px', borderRadius: '5px', border: 'none', marginRight: '10px', width: '250px' }}
        />
        <button type="submit" style={{ padding: '10px 20px', borderRadius: '5px', backgroundColor: '#06b6d4', color: 'white', border: 'none', cursor: 'pointer' }}>
          Añadir
        </button>
      </form>

      {todos.length === 0 && !loading && (
        <p style={{ textAlign: 'center', color: '#94a3b8', marginTop: '20px' }}>
          No hay tareas pendientes. ¡Buen trabajo!
        </p>
      )}

      {loading ? <p>Cargando tareas...</p> : (
        <ul style={{ listStyle: 'none', padding: 0 }}>
          {todos.map((item) => (
            <li key={item.id} style={{ background: '#1e293b', padding: '15px', marginBottom: '10px', borderRadius: '10px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              
              {editingId === item.id ? (
                <div style={{ flexGrow: 1, display: 'flex', gap: '10px', alignItems: 'center' }}>
                  <input 
                    value={editText} 
                    onChange={(e) => setEditText(e.target.value)}
                    style={{ padding: '8px', borderRadius: '5px', border: 'none', flexGrow: 1, outline: 'none' }}
                    autoFocus 
                  />
                  <button onClick={() => updateTodoName(item)} style={{ backgroundColor: '#22c55e', color: 'white', border: 'none', padding: '8px 12px', borderRadius: '5px', cursor: 'pointer' }}>Guardar</button>
                  <button onClick={() => setEditingId(null)} style={{ backgroundColor: '#64748b', color: 'white', border: 'none', padding: '8px 12px', borderRadius: '5px', cursor: 'pointer' }}>Cancelar</button>
                </div>
              ) : (
                <>
                  <span 
                    onClick={() => toggleStatus(item)} 
                    style={{ 
                      cursor: 'pointer', flexGrow: 1,
                      textDecoration: item.status === 'hecho' ? 'line-through' : 'none',
                      color: item.status === 'hecho' ? '#94a3b8' : 'white',
                      userSelect: 'none'
                    }}
                  >
                    {item.todo} - <strong>{item.status}</strong>
                  </span>

                  <div style={{ display: 'flex', gap: '10px' }}>
                    <button 
                      onClick={() => { setEditingId(item.id); setEditText(item.todo); }} 
                      style={{ backgroundColor: '#eab308', color: 'white', border: 'none', padding: '5px 10px', borderRadius: '5px', cursor: 'pointer' }}
                    >
                      Editar
                    </button>
                    <button 
                      onClick={() => deleteTodo(item.id)} 
                      style={{ backgroundColor: '#ef4444', color: 'white', border: 'none', padding: '5px 10px', borderRadius: '5px', cursor: 'pointer' }}
                    >
                      Eliminar
                    </button>
                  </div>
                </>
              )}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

export default App;
