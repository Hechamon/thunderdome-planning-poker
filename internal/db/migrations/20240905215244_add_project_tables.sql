-- +goose Up
-- +goose StatementBegin

-- Projects table
CREATE TABLE thunderdome.project (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    organization_id UUID REFERENCES thunderdome.organization(id),
    department_id UUID REFERENCES thunderdome.organization_department(id),
    team_id UUID REFERENCES thunderdome.team(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX ON thunderdome.project (organization_id);
CREATE INDEX ON thunderdome.project (department_id);
CREATE INDEX ON thunderdome.project (team_id);

-- Project Epic table
CREATE TABLE thunderdome.project_epic (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES thunderdome.project(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(20) CHECK (status IN ('not_started', 'in_progress', 'completed')),
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX ON thunderdome.project_epic (project_id);

-- Team Sprint table
CREATE TABLE thunderdome.team_sprint (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id UUID REFERENCES thunderdome.team(id),
    name VARCHAR(255) NOT NULL,
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    status VARCHAR(20) CHECK (status IN ('planned', 'active', 'completed', 'cancelled')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX ON thunderdome.team_sprint (team_id);

-- Sprint Project table
CREATE TABLE thunderdome.sprint_project (
    sprint_id UUID REFERENCES thunderdome.team_sprint(id),
    project_id UUID REFERENCES thunderdome.project(id),
    PRIMARY KEY (sprint_id, project_id)
);
CREATE INDEX ON thunderdome.sprint_project (sprint_id);
CREATE INDEX ON thunderdome.sprint_project (project_id);

-- Project Story table
CREATE TABLE thunderdome.project_story (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES thunderdome.project(id),
    sprint_id UUID REFERENCES thunderdome.team_sprint(id),
    epic_id UUID REFERENCES thunderdome.project_epic(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(20) CHECK (type IN ('story', 'spike', 'bug', 'task', 'sub_task')),
    status VARCHAR(20) CHECK (status IN ('backlog', 'to_do', 'in_progress', 'in_review', 'done', 'blocked')),
    priority VARCHAR(20) CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    story_points INTEGER,
    rank VARCHAR(16) NOT NULL,
    parent_id UUID REFERENCES thunderdome.project_story(id),
    created_by UUID NOT NULL REFERENCES thunderdome.users(id),
    external_reference_id VARCHAR(100),
    external_reference_link TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX ON thunderdome.project_story (project_id);
CREATE INDEX ON thunderdome.project_story (sprint_id);
CREATE INDEX ON thunderdome.project_story (epic_id);
CREATE INDEX ON thunderdome.project_story (status);
CREATE INDEX ON thunderdome.project_story (rank);
CREATE INDEX ON thunderdome.project_story (created_by);
CREATE INDEX ON thunderdome.project_story (parent_id);
CREATE INDEX ON thunderdome.project_story (type);
CREATE INDEX ON thunderdome.project_story (external_reference_id);

-- Project Story Assignment table
CREATE TABLE thunderdome.project_story_assignment (
    story_id UUID REFERENCES thunderdome.project_story(id),
    user_id UUID REFERENCES thunderdome.users(id),
    assigned_by UUID REFERENCES thunderdome.users(id),
    assigned_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (story_id, user_id)
);
CREATE INDEX ON thunderdome.project_story_assignment (story_id);
CREATE INDEX ON thunderdome.project_story_assignment (user_id);
CREATE INDEX ON thunderdome.project_story_assignment (assigned_by);

-- Project Story Close Tracking table
CREATE TABLE thunderdome.project_story_close (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    story_id UUID NOT NULL REFERENCES thunderdome.project_story(id),
    reason VARCHAR(50) NOT NULL,
    closed_by UUID NOT NULL REFERENCES thunderdome.users(id),
    comment TEXT,
    closed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX ON thunderdome.project_story_close (story_id);
CREATE INDEX ON thunderdome.project_story_close (closed_by);
CREATE INDEX ON thunderdome.project_story_close (closed_at);

-- Project Label table
CREATE TABLE thunderdome.project_label (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES thunderdome.project(id),
    name VARCHAR(50) NOT NULL,
    color VARCHAR(7) DEFAULT '#FFFFFF',
    UNIQUE (project_id, name)
);
CREATE INDEX ON thunderdome.project_label (project_id);

-- Project Story_Label table (junction table)
CREATE TABLE thunderdome.project_story_label (
    story_id UUID REFERENCES thunderdome.project_story(id),
    label_id UUID REFERENCES thunderdome.project_label(id),
    PRIMARY KEY (story_id, label_id)
);
CREATE INDEX ON thunderdome.project_story_label (story_id);
CREATE INDEX ON thunderdome.project_story_label (label_id);

-- Project Milestone table
CREATE TABLE thunderdome.project_milestone (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES thunderdome.project(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    target_date TIMESTAMPTZ,
    status VARCHAR(20) CHECK (status IN ('planned', 'in_progress', 'completed', 'cancelled')),
    release_id UUID REFERENCES thunderdome.project_release(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX ON thunderdome.project_milestone (project_id);
CREATE INDEX ON thunderdome.project_milestone (target_date);
CREATE INDEX ON thunderdome.project_milestone (status);
CREATE INDEX ON thunderdome.project_milestone (release_id);

-- Project Roadmap table
CREATE TABLE thunderdome.project_roadmap (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES thunderdome.project(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX ON thunderdome.project_roadmap (project_id);

-- Roadmap Item table
CREATE TABLE thunderdome.roadmap_item (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    roadmap_id UUID NOT NULL REFERENCES thunderdome.project_roadmap(id),
    item_type VARCHAR(20) CHECK (item_type IN ('epic', 'story')),
    item_id UUID NOT NULL,
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    status VARCHAR(20) CHECK (status IN ('not_started', 'in_progress', 'completed')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX ON thunderdome.roadmap_item (roadmap_id);
CREATE INDEX ON thunderdome.roadmap_item (item_type, item_id);
CREATE INDEX ON thunderdome.roadmap_item (status);

ALTER TABLE thunderdome.roadmap_item
ADD CONSTRAINT roadmap_item_reference
CHECK (
    (item_type = 'epic' AND item_id IN (SELECT id FROM thunderdome.project_epic)) OR
    (item_type = 'story' AND item_id IN (SELECT id FROM thunderdome.project_story))
);

-- Project Release table
CREATE TABLE thunderdome.project_release (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES thunderdome.project(id),
    name VARCHAR(255) NOT NULL,
    version VARCHAR(50),
    description TEXT,
    release_date TIMESTAMPTZ,
    status VARCHAR(20) CHECK (status IN ('planned', 'in_progress', 'released', 'cancelled')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX ON thunderdome.project_release (project_id);
CREATE INDEX ON thunderdome.project_release (release_date);
CREATE INDEX ON thunderdome.project_release (status);

-- Release Team table
CREATE TABLE thunderdome.release_team (
    release_id UUID NOT NULL REFERENCES thunderdome.project_release(id),
    team_id UUID NOT NULL REFERENCES thunderdome.team(id),
    PRIMARY KEY (release_id, team_id)
);
CREATE INDEX ON thunderdome.release_team (release_id);
CREATE INDEX ON thunderdome.release_team (team_id);

-- Release Item table
CREATE TABLE thunderdome.release_item (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    release_id UUID NOT NULL REFERENCES thunderdome.project_release(id),
    item_type VARCHAR(20) CHECK (item_type IN ('epic', 'story')),
    item_id UUID NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX ON thunderdome.release_item (release_id);
CREATE INDEX ON thunderdome.release_item (item_type, item_id);

ALTER TABLE thunderdome.release_item
ADD CONSTRAINT release_item_reference
CHECK (
    (item_type = 'epic' AND item_id IN (SELECT id FROM thunderdome.project_epic)) OR
    (item_type = 'story' AND item_id IN (SELECT id FROM thunderdome.project_story))
);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE thunderdome.release_item;
DROP TABLE thunderdome.release_team;
DROP TABLE thunderdome.project_release;
DROP TABLE thunderdome.roadmap_item;
DROP TABLE thunderdome.project_roadmap;
DROP TABLE thunderdome.project_milestone;
DROP TABLE thunderdome.project_story_label;
DROP TABLE thunderdome.project_label;
DROP TABLE thunderdome.project_story_close;
DROP TABLE thunderdome.project_story_assignment;
DROP TABLE thunderdome.project_story;
DROP TABLE thunderdome.sprint_project;
DROP TABLE thunderdome.team_sprint;
DROP TABLE thunderdome.project_epic;
DROP TABLE thunderdome.project;
-- +goose StatementEnd