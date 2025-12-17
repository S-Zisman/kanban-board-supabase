-- Создание таблицы для задач Kanban доски
-- Выполните этот SQL скрипт в Supabase SQL Editor:
-- 1. Откройте ваш проект в Supabase Dashboard
-- 2. Перейдите в SQL Editor
-- 3. Скопируйте и вставьте этот код
-- 4. Нажмите "Run"

CREATE TABLE IF NOT EXISTS tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    text TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('todo', 'inProgress', 'done')),
    position INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Включаем Row Level Security (RLS)
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- Создаем политику, которая разрешает всем читать и изменять задачи
-- (для продакшена нужно настроить аутентификацию и более строгие политики)
CREATE POLICY "Enable all access for tasks" ON tasks
    FOR ALL
    USING (true)
    WITH CHECK (true);

-- Создаем индекс для быстрой сортировки по статусу и позиции
CREATE INDEX IF NOT EXISTS tasks_status_position_idx ON tasks(status, position);

-- Функция для автоматического обновления updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Триггер для автоматического обновления updated_at
CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
