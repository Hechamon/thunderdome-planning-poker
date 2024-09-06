-- +goose Up
-- +goose StatementBegin
-- Projects table
-- Project table
-- Project table
CREATE TABLE project (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    organization_id UUID REFERENCES organization(id),
    department_id UUID REFERENCES organization_department(id),
    team_id UUID REFERENCES team(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX ON project (organization_id);
CREATE INDEX ON project (department_id);
CREATE INDEX ON project (team_id);

-- Project Sprint table
CREATE TABLE project_sprint (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES project(id),
    name VARCHAR(255) NOT NULL,
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    status VARCHAR(20) CHECK (status IN ('planned', 'active', 'completed', 'cancelled')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX ON project_sprint (project_id);

-- Project Story table
CREATE TABLE project_story (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES project(id),
    sprint_id UUID REFERENCES project_sprint(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(20) CHECK (type IN ('story', 'spike', 'bug', 'task', 'epic', 'sub_task')),
    status VARCHAR(20) CHECK (status IN ('backlog', 'to_do', 'in_progress', 'in_review', 'done', 'blocked')),
    priority VARCHAR(20) CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    story_points INTEGER,
    rank VARCHAR(16) NOT NULL,
    parent_id UUID REFERENCES project_story(id),
    created_by UUID NOT NULL REFERENCES users(id),
    assigned_to UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX ON project_story (project_id);
CREATE INDEX ON project_story (sprint_id);
CREATE INDEX ON project_story (status);
CREATE INDEX ON project_story (rank);
CREATE INDEX ON project_story (created_by);
CREATE INDEX ON project_story (assigned_to);
CREATE INDEX ON project_story (parent_id);
CREATE INDEX ON project_story (type);

-- Project Tag table
CREATE TABLE project_tag (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) UNIQUE NOT NULL,
    color VARCHAR(7) DEFAULT '#FFFFFF'
);

-- Project Story_Tag table (junction table)
CREATE TABLE project_story_tag (
    story_id UUID REFERENCES project_story(id),
    tag_id UUID REFERENCES project_tag(id),
    PRIMARY KEY (story_id, tag_id)
);
CREATE INDEX ON project_story_tag (story_id);
CREATE INDEX ON project_story_tag (tag_id);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE project_story_tag;
DROP TABLE project_tag;
DROP TABLE project_story;
DROP TABLE project_sprint;
DROP TABLE project;
-- +goose StatementEnd
