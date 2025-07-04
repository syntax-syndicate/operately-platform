import * as React from "react";

import { IconBuilding } from "turboui";

import { PermissionLevels } from "@/features/Permissions";

import Forms from "@/components/Forms";

type Option = { value: PermissionLevels; label: string };

export function AccessSelectors() {
  const [companyMembersOptions] = Forms.useFieldValue<Option[]>("access.companyMembersOptions");

  return (
    <div className="mt-6">
      <Forms.FieldGroup layout="horizontal" layoutOptions={{ dividers: true, ratio: "1:1" }}>
        <Forms.SelectBox
          field={"access.companyMembers"}
          label="Company members"
          labelIcon={<IconBuilding size={20} />}
          options={companyMembersOptions}
          hidden={shouldHide(companyMembersOptions)}
        />
      </Forms.FieldGroup>
    </div>
  );
}

function shouldHide(options: Option[]) {
  return options.length === 1 && options[0]!.value === PermissionLevels.NO_ACCESS;
}
