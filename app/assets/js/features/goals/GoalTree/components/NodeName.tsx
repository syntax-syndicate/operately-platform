import * as React from "react";

import { DivLink } from "turboui";
import { Node, ProjectNode } from "../tree";

import { PrivacyIndicator } from "@/features/Permissions";
import { usePaths } from "@/routes/paths";
import classNames from "classnames";

interface NodeNameProps {
  node: Node;
  target?: React.HTMLAttributeAnchorTarget;
}

export function NodeName({ node, target = "_self" }: NodeNameProps) {
  const paths = usePaths();
  const titleClass = classNames("decoration-content-subtle hover:underline truncate");

  return (
    <div className="flex items-center gap-1 truncate">
      <DivLink to={node.linkTo(paths)} className={titleClass} target={target}>
        {node.name}
      </DivLink>

      {node.type === "project" && (
        <PrivacyIndicator resource={(node as ProjectNode).project} type="project" size={16} />
      )}
    </div>
  );
}
